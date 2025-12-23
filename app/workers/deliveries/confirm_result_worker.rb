# typed: false

module Deliveries
  # ConfirmResultWorker syncs delivery results from Blastengine
  # for a single record and updates DeliveryRecipient statuses
  #
  # Called by OrchestratorWorker with (type, record_id, tenant_id)
  # Runs every 15 minutes (at :00, :15, :30, :45)
  class ConfirmResultWorker
    include Sidekiq::Worker
    include Concerns::TenantContext

    sidekiq_options queue: :low_priority, retry: 3, unique_for: 5.minutes

    def perform(type, record_id, tenant_id)
      set_tenant_context_by_id(tenant_id)

      Sentry.set_context('worker', {
        class: self.class.name,
        type: type,
        record_id: record_id,
      },)

      case type
      when 'schedule'
        schedule = DeliverySchedule.find_by(id: record_id)
        process_schedule(schedule) if schedule
      when 'birthday'
        birthday = DeliveryBirthday.find_by(id: record_id)
        process_birthday(birthday) if birthday
      end
    rescue StandardError => e
      Rails.logger.error("[ConfirmResultWorker] #{type} #{record_id} failed: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n"))
      raise # Re-raise for Sidekiq retry
    end

    private

    def process_schedule(schedule)
      return unless schedule.delivering? # Status guard

      result = FixedTime::ConfirmResultService.new(schedule: schedule).execute
      if result[:success]
        Rails.logger.info("[ConfirmResultWorker] Schedule #{schedule.id} synced #{result[:synced]} logs")
      else
        capture_soft_failure(
          '[ConfirmResultWorker] Schedule result sync failed',
          context: {
            type: 'schedule',
            schedule_id: schedule.id,
            delivery_id: schedule.delivery_id,
            error: result[:error],
          },
        )
      end
    end

    def process_birthday(birthday)
      return unless birthday.delivering? # Status guard

      result = Birthday::ConfirmResultService.new(birthday: birthday).execute
      if result[:success]
        Rails.logger.info("[ConfirmResultWorker] Birthday #{birthday.id} synced #{result[:synced]} logs")
      else
        capture_soft_failure(
          '[ConfirmResultWorker] Birthday result sync failed',
          context: {
            type: 'birthday',
            birthday_id: birthday.id,
            delivery_id: birthday.delivery_id,
            error: result[:error],
          },
        )
      end
    end
  end
end
