# typed: false

module Deliveries
  # ConfirmImportWorker checks CSV import status for a single record
  # and commits the delivery when import is complete
  #
  # Called by OrchestratorWorker with (type, record_id, tenant_id)
  class ConfirmImportWorker
    include Sidekiq::Worker
    include Concerns::TenantContext

    sidekiq_options queue: :default, retry: 3

    # Blastengine job statuses:
    # WAIT (待ち), STARTED (処理中), FINISHED (完了), FAILED (失敗),
    # STOP (停止), SYSTEM_ERROR (システムエラー), TIMEOUT (タイムアウト)
    FINISHED_STATUS = 'FINISHED'.freeze
    ERROR_STATUSES = %w[FAILED STOP SYSTEM_ERROR TIMEOUT].freeze

    def perform(type, record_id, tenant_id)
      set_tenant_context_by_id(tenant_id)

      case type
      when 'schedule'
        schedule = DeliverySchedule.find_by(id: record_id)
        process_schedule(schedule) if schedule
      when 'birthday'
        birthday = DeliveryBirthday.find_by(id: record_id)
        process_birthday(birthday) if birthday
      end
    rescue StandardError => e
      error_detail = build_error_detail(e)
      Rails.logger.error("[ConfirmImportWorker] #{type} #{record_id} failed: #{error_detail}")
      Rails.logger.error(e.backtrace.first(5).join("\n"))

      # Capture API error details in Sentry for debugging
      if e.respond_to?(:body) && e.respond_to?(:status)
        Sentry.set_context('api_error', {
          status: e.status,
          body: e.body,
        })
      end

      raise # Re-raise for Sidekiq retry
    end

    private

    def build_error_detail(error)
      return error.message unless error.respond_to?(:body)

      body = error.body
      return error.message if body.blank?

      "#{error.message} | API: #{body}"
    end

    def process_schedule(schedule)
      return unless schedule.preparing? # Status guard
      return if schedule.blastengine_job_id.blank?

      Sentry.set_context('schedule', {
        id: schedule.id,
        delivery_id: schedule.delivery_id,
        blastengine_job_id: schedule.blastengine_job_id,
        scheduled_at: schedule.scheduled_at&.iso8601,
      },)

      api = Blastengine::API.new
      result = api.bulk_import_status(job_id: schedule.blastengine_job_id.to_s)

      case result['status']
      when FINISHED_STATUS
        # Commit with reservation
        reservation_time = schedule.scheduled_at.iso8601
        api.bulk_commit(
          delivery_id: schedule.blastengine_delivery_id.to_i,
          reservation_time: reservation_time,
        )

        # Update status and record event
        schedule.update!(status: 'delivering', setup_completed_at: Time.current)
        record_schedule_event(schedule)

        Rails.logger.info("[ConfirmImportWorker] Schedule #{schedule.id} committed at #{reservation_time}")
      when *ERROR_STATUSES
        Rails.logger.error("[ConfirmImportWorker] Schedule #{schedule.id} import failed: #{result['status']}")
        capture_soft_failure(
          '[ConfirmImportWorker] Blastengine import failed',
          context: {
            type: 'schedule',
            record_id: schedule.id,
            blastengine_job_id: schedule.blastengine_job_id,
            blastengine_status: result['status'],
            api_response: result,
          },
        )
        # Keep in preparing status for manual intervention
      else
        # WAIT or STARTED - still importing, check again next minute
        Rails.logger.debug { "[ConfirmImportWorker] Schedule #{schedule.id} still importing: #{result['status']}" }
      end
    end

    def process_birthday(birthday)
      return unless birthday.preparing? # Status guard
      return if birthday.blastengine_job_id.blank?

      Sentry.set_context('birthday', {
        id: birthday.id,
        delivery_id: birthday.delivery_id,
        blastengine_job_id: birthday.blastengine_job_id,
        delivery_time: birthday.delivery_time,
      },)

      api = Blastengine::API.new
      result = api.bulk_import_status(job_id: birthday.blastengine_job_id.to_s)

      case result['status']
      when FINISHED_STATUS
        # Commit with reservation
        hour, minute = birthday.delivery_time.split(':').map(&:to_i)
        today = Date.current
        reservation_time = Time.zone.local(today.year, today.month, today.day, hour, minute).iso8601
        api.bulk_commit(
          delivery_id: birthday.blastengine_delivery_id.to_i,
          reservation_time: reservation_time,
        )

        # Update status
        birthday.update!(status: 'delivering', setup_completed_at: Time.current)

        Rails.logger.info("[ConfirmImportWorker] Birthday #{birthday.id} committed at #{reservation_time}")
      when *ERROR_STATUSES
        Rails.logger.error("[ConfirmImportWorker] Birthday #{birthday.id} import failed: #{result['status']}")
        capture_soft_failure(
          '[ConfirmImportWorker] Blastengine birthday import failed',
          context: {
            type: 'birthday',
            record_id: birthday.id,
            blastengine_job_id: birthday.blastengine_job_id,
            blastengine_status: result['status'],
            api_response: result,
          },
        )
        # Reset to ongoing so it can retry tomorrow
        birthday.update!(status: 'ongoing', blastengine_job_id: nil)
      else
        # WAIT or STARTED - still importing, check again next minute
        Rails.logger.debug { "[ConfirmImportWorker] Birthday #{birthday.id} still importing: #{result['status']}" }
      end
    end

    def record_schedule_event(schedule)
      delivery = schedule.delivery
      return unless delivery

      DeliveryEvent.record!(
        delivery: delivery,
        event: DeliveryEvent::Type::Started.new,
        admin: nil,
      )
    end

  end
end
