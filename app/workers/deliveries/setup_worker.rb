# typed: false

module Deliveries
  # SetupWorker runs every minute and prepares scheduled deliveries
  # for Blastengine bulk sending ~15 minutes before scheduled_at
  class SetupWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default, retry: false

    # How many minutes before scheduled_at to start setup
    SETUP_MINUTES_BEFORE = 15

    # Runs every minute via sidekiq-scheduler
    def perform
      cutoff_time = Time.current + SETUP_MINUTES_BEFORE.minutes

      # Find scheduled deliveries due for setup
      DeliverySchedule.where(status: 'scheduled')
                      .where('scheduled_at <= ?', cutoff_time)
                      .find_each do |schedule|
        set_tenant_context(schedule.tenant)
        process_setup(schedule)
      end
    end

    private

    def set_tenant_context(tenant)
      RequestStore.store[:current_tenant_domain] = tenant.domain
      Tenant.current
    end

    def process_setup(schedule)
      Rails.logger.info("[SetupWorker] Processing schedule #{schedule.id}")

      result = FixedTime::SetupService.new(schedule: schedule).execute

      if result[:success]
        Rails.logger.info("[SetupWorker] #{schedule.id} setup complete")
      else
        Rails.logger.error("[SetupWorker] #{schedule.id} failed: #{result[:error]}")
      end
    rescue StandardError => e
      Rails.logger.error("[SetupWorker] Error processing #{schedule.id}: #{e.message}")
      Rails.logger.error(e.backtrace.first(5).join("\n"))
    end
  end
end
