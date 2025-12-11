# typed: false

module Deliveries
  # ConfirmResultWorker runs every 5 minutes to sync delivery results
  # from Blastengine and update DeliveryRecipient statuses
  class ConfirmResultWorker
    include Sidekiq::Worker

    sidekiq_options queue: :low_priority, retry: false

    # Runs every 5 minutes via sidekiq-scheduler
    def perform
      # Sync scheduled deliveries
      sync_scheduled_deliveries

      # Sync birthday deliveries
      sync_birthday_deliveries
    end

    private

    def sync_scheduled_deliveries
      DeliverySchedule.where(status: 'delivering').find_each do |schedule|
        # Only sync deliveries that have passed their scheduled time
        next if schedule.scheduled_at > Time.current

        set_tenant_context(schedule.tenant)

        result = ConfirmResultService.new(schedule: schedule).execute
        Rails.logger.info("[ConfirmResultWorker] Schedule #{schedule.id} synced #{result[:synced]} logs") if result[:success]
      end
    end

    def sync_birthday_deliveries
      DeliveryBirthday.where(status: 'delivering').find_each do |birthday|
        # Only sync if delivery_time has passed
        next unless delivery_time_passed?(birthday)

        set_tenant_context(birthday.tenant)

        result = Birthday::ConfirmResultService.new(birthday: birthday).execute
        Rails.logger.info("[ConfirmResultWorker] Birthday #{birthday.id} synced #{result[:synced]} logs") if result[:success]
      end
    end

    def delivery_time_passed?(birthday)
      now = Time.current
      hour, minute = birthday.delivery_time.split(':').map(&:to_i)
      delivery_datetime = Time.zone.local(now.year, now.month, now.day, hour, minute)
      now > delivery_datetime
    end

    def set_tenant_context(tenant)
      RequestStore.store[:current_tenant_domain] = tenant.domain
      Tenant.current
    end
  end
end
