# typed: false

module Deliveries
  # ConfirmImportWorker runs every minute to check CSV import status
  # and commit deliveries when import is complete
  #
  # Handles both DeliverySchedule and DeliveryBirthday with status='preparing'
  class ConfirmImportWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default, retry: false

    # Blastengine job statuses:
    # WAIT (待ち), STARTED (処理中), FINISHED (完了), FAILED (失敗),
    # STOP (停止), SYSTEM_ERROR (システムエラー), TIMEOUT (タイムアウト)
    FINISHED_STATUS = 'FINISHED'.freeze
    ERROR_STATUSES = %w[FAILED STOP SYSTEM_ERROR TIMEOUT].freeze

    def perform
      confirm_scheduled_deliveries
      confirm_birthday_deliveries
    end

    private

    def confirm_scheduled_deliveries
      DeliverySchedule.where(status: 'preparing').find_each do |schedule|
        set_tenant_context(schedule.tenant)
        process_schedule(schedule)
      rescue StandardError => e
        Rails.logger.error("[ConfirmImportWorker] Schedule #{schedule.id} failed: #{e.message}")
      end
    end

    def confirm_birthday_deliveries
      DeliveryBirthday.where(status: 'preparing').find_each do |birthday|
        set_tenant_context(birthday.tenant)
        process_birthday(birthday)
      rescue StandardError => e
        Rails.logger.error("[ConfirmImportWorker] Birthday #{birthday.id} failed: #{e.message}")
      end
    end

    def process_schedule(schedule)
      return if schedule.blastengine_job_id.blank?

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
        # Keep in preparing status for manual intervention
      else
        # WAIT or STARTED - still importing, check again next minute
        Rails.logger.debug { "[ConfirmImportWorker] Schedule #{schedule.id} still importing: #{result['status']}" }
      end
    end

    def process_birthday(birthday)
      return if birthday.blastengine_job_id.blank?

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

    def set_tenant_context(tenant)
      RequestStore.store[:current_tenant_domain] = tenant.domain
      Tenant.current
    end
  end
end
