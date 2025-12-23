# typed: false

module Deliveries
  # OrchestratorWorker runs every minute via sidekiq-scheduler
  # Finds work that needs to be done and dispatches async jobs for each record
  #
  # Benefits over previous 4 scheduled jobs:
  # - Single DB scan per minute instead of 4
  # - Per-record parallelism (each delivery processed independently)
  # - Individual retry on failure
  # - Easier monitoring and debugging
  class OrchestratorWorker
    include Sidekiq::Worker

    sidekiq_options queue: :default, retry: false

    SETUP_MINUTES_BEFORE = 15
    RESULT_SYNC_INTERVAL = 15 # minutes

    def perform
      Sentry.set_context('orchestrator', {
        started_at: Time.current.iso8601,
        result_sync_enabled: should_sync_results?,
      },)

      dispatch_schedule_setups
      dispatch_birthday_setups
      dispatch_import_confirmations
      dispatch_result_syncs if should_sync_results?
    rescue StandardError => e
      # Capture any unexpected errors in orchestrator
      Rails.logger.error("[OrchestratorWorker] Unexpected error: #{e.message}")
      raise # Re-raise for Sentry to capture with context
    end

    private

    # Find scheduled deliveries due for setup (15 min before scheduled_at)
    def dispatch_schedule_setups
      cutoff = Time.current + SETUP_MINUTES_BEFORE.minutes

      DeliverySchedule.where(status: 'scheduled')
                      .where('scheduled_at <= ?', cutoff)
                      .pluck(:id, :tenant_id)
                      .each do |id, tenant_id|
        FixedTime::SetupWorker.perform_async(id, tenant_id)
      end
    end

    # Find birthday deliveries that might need setup
    # Birthday::SetupWorker will check if within setup window
    def dispatch_birthday_setups
      today = Date.current

      DeliveryBirthday.where(status: 'ongoing').find_each do |birthday|
        # Skip if already setup for today
        next if birthday.last_setup_date == today && birthday.setup_completed_at.present?

        Birthday::SetupWorker.perform_async(birthday.id, birthday.tenant_id)
      end
    end

    # Find preparing records needing import confirmation
    def dispatch_import_confirmations
      # Schedules
      DeliverySchedule.where(status: 'preparing')
                      .where.not(blastengine_job_id: nil)
                      .pluck(:id, :tenant_id)
                      .each do |id, tenant_id|
        ConfirmImportWorker.perform_async('schedule', id, tenant_id)
      end

      # Birthdays
      DeliveryBirthday.where(status: 'preparing')
                      .where.not(blastengine_job_id: nil)
                      .pluck(:id, :tenant_id)
                      .each do |id, tenant_id|
        ConfirmImportWorker.perform_async('birthday', id, tenant_id)
      end
    end

    # Find delivering records needing result sync
    def dispatch_result_syncs
      # Schedules past their scheduled_at time
      DeliverySchedule.where(status: 'delivering')
                      .where('scheduled_at <= ?', Time.current)
                      .pluck(:id, :tenant_id)
                      .each do |id, tenant_id|
        ConfirmResultWorker.perform_async('schedule', id, tenant_id)
      end

      # Birthdays past their delivery_time
      now = Time.current
      DeliveryBirthday.where(status: 'delivering').find_each do |birthday|
        next unless delivery_time_passed?(now, birthday.delivery_time)

        ConfirmResultWorker.perform_async('birthday', birthday.id, birthday.tenant_id)
      end
    end

    def should_sync_results?
      # Only run result sync at :00, :15, :30, :45
      (Time.current.min % RESULT_SYNC_INTERVAL).zero?
    end

    def delivery_time_passed?(now, delivery_time_string)
      hour, minute = delivery_time_string.split(':').map(&:to_i)
      delivery_datetime = Time.zone.local(now.year, now.month, now.day, hour, minute)
      now > delivery_datetime
    end
  end
end
