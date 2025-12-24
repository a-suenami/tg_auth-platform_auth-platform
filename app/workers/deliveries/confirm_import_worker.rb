# typed: false

module Deliveries
  # ConfirmImportWorker checks CSV import status for a single record
  # and commits the delivery when import is complete
  #
  # Called by OrchestratorWorker with (type, record_id, tenant_id)
  class ConfirmImportWorker
    include Sidekiq::Worker
    include Concerns::TenantContext

    sidekiq_options queue: :default, retry: 3, unique_for: 2.minutes

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
        },)
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
        commit_schedule(schedule, api)
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

    def commit_schedule(schedule, api)
      delivery_id = schedule.blastengine_delivery_id.to_i

      # Validate Blastengine delivery still exists before committing
      unless validate_blastengine_delivery(delivery_id, api)
        Rails.logger.error("[ConfirmImportWorker] Blastengine delivery #{delivery_id} not found, resetting schedule #{schedule.id}")
        Sentry.capture_message(
          '[ConfirmImportWorker] Blastengine delivery not found, resetting schedule',
          level: :warning,
          extra: {
            schedule_id: schedule.id,
            blastengine_delivery_id: delivery_id,
          },
        )
        schedule.update!(
          status: 'scheduled',
          blastengine_delivery_id: nil,
          blastengine_job_id: nil,
        )
        return
      end

      if schedule.scheduled_at > Time.current
        # Normal: schedule for future
        api.bulk_commit(
          delivery_id: delivery_id,
          reservation_time: schedule.scheduled_at.iso8601,
        )
        Rails.logger.info("[ConfirmImportWorker] Schedule #{schedule.id} committed at #{schedule.scheduled_at.iso8601}")
      else
        # Fallback: send immediately (scheduled_at has passed)
        delay_minutes = ((Time.current - schedule.scheduled_at) / 60).round
        Rails.logger.warn("[ConfirmImportWorker] Schedule #{schedule.id} past scheduled_at by #{delay_minutes} minutes, sending immediately")

        Sentry.capture_message(
          '[ConfirmImportWorker] Sending past-due delivery immediately',
          level: :warning,
          extra: {
            schedule_id: schedule.id,
            scheduled_at: schedule.scheduled_at.iso8601,
            current_time: Time.current.iso8601,
            delay_minutes: delay_minutes,
          },
        )

        api.bulk_commit_immediate(delivery_id: delivery_id)
      end

      schedule.update!(status: 'delivering', setup_completed_at: Time.current)
      record_schedule_event(schedule)
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
        commit_birthday(birthday, api)
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

    def commit_birthday(birthday, api)
      delivery_id = birthday.blastengine_delivery_id.to_i

      # Validate Blastengine delivery still exists before committing
      unless validate_blastengine_delivery(delivery_id, api)
        Rails.logger.error("[ConfirmImportWorker] Blastengine delivery #{delivery_id} not found, resetting birthday #{birthday.id}")
        Sentry.capture_message(
          '[ConfirmImportWorker] Blastengine delivery not found, resetting birthday',
          level: :warning,
          extra: {
            birthday_id: birthday.id,
            blastengine_delivery_id: delivery_id,
          },
        )
        birthday.update!(
          status: 'ongoing',
          blastengine_delivery_id: nil,
          blastengine_job_id: nil,
        )
        return
      end

      # Calculate today's delivery datetime from delivery_time (e.g., "09:00")
      hour, minute = birthday.delivery_time.split(':').map(&:to_i)
      today = Date.current
      delivery_datetime = Time.zone.local(today.year, today.month, today.day, hour, minute)

      if delivery_datetime > Time.current
        # Normal: schedule for future
        api.bulk_commit(
          delivery_id: delivery_id,
          reservation_time: delivery_datetime.iso8601,
        )
        Rails.logger.info("[ConfirmImportWorker] Birthday #{birthday.id} committed at #{delivery_datetime.iso8601}")
      else
        # Fallback: send immediately (delivery_time has passed)
        Rails.logger.warn("[ConfirmImportWorker] Birthday #{birthday.id} past delivery_time #{birthday.delivery_time}, sending immediately")

        Sentry.capture_message(
          '[ConfirmImportWorker] Sending past-due birthday delivery immediately',
          level: :warning,
          extra: {
            birthday_id: birthday.id,
            delivery_time: birthday.delivery_time,
            current_time: Time.current.iso8601,
          },
        )

        api.bulk_commit_immediate(delivery_id: delivery_id)
      end

      birthday.update!(status: 'delivering', setup_completed_at: Time.current)
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

    # Check if Blastengine delivery still exists (not deleted by cleanup or other means)
    def validate_blastengine_delivery(delivery_id, api)
      return false if delivery_id.blank? || delivery_id.zero?

      api.delivery_detail(delivery_id: delivery_id)
      true
    rescue Exceptions::API::ServerError => e
      # 404 means delivery was deleted
      return false if T.unsafe(e).status.to_i == 404

      # Other API errors - assume delivery exists to avoid false resets
      Rails.logger.warn("[ConfirmImportWorker] Could not validate delivery #{delivery_id}: #{e.message}")
      true
    rescue StandardError => e
      # On unexpected error, assume delivery exists to avoid false resets
      Rails.logger.warn("[ConfirmImportWorker] Could not validate delivery #{delivery_id}: #{e.message}")
      true
    end

  end
end
