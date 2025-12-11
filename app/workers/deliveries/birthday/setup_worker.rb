# typed: false

module Deliveries
  module Birthday
    # SetupWorker runs every minute via sidekiq-scheduler
    # Finds birthday deliveries that need setup (15 mins before delivery_time)
    # and triggers Birthday::SetupService for each
    class SetupWorker
      include Sidekiq::Worker

      sidekiq_options queue: :default, retry: false

      SETUP_MINUTES_BEFORE = 15

      def perform
        Tenant.find_each do |tenant|
          RequestStore.store[:current_tenant_domain] = tenant.domain
          Tenant.current
          process_tenant(tenant)
        end
      end

      private

      def process_tenant(tenant)
        now = Time.current
        today = Date.current

        # Find ongoing birthday deliveries for this tenant
        DeliveryBirthday.ongoing.where(tenant_id: tenant.id).find_each do |birthday|
          # Skip if already setup for today
          next if birthday.last_setup_date == today && birthday.setup_completed_at.present?

          # Check if within setup window (15 mins before delivery_time)
          next unless within_setup_window?(now, birthday.delivery_time)

          Rails.logger.info(
            "[Birthday::SetupWorker] Setting up delivery #{birthday.delivery_id} for tenant #{tenant.id}",
          )

          result = Deliveries::Birthday::SetupService.new(birthday: birthday).execute

          if result[:success]
            Rails.logger.info(
              "[Birthday::SetupWorker] Setup complete: #{result[:users_count] || 0} users",
            )
          else
            Rails.logger.error(
              "[Birthday::SetupWorker] Setup failed: #{result[:error]}",
            )
          end
        end
      end

      def within_setup_window?(now, delivery_time_string)
        hour, minute = delivery_time_string.split(':').map(&:to_i)
        delivery_datetime = Time.zone.local(now.year, now.month, now.day, hour, minute)

        # Setup window: from SETUP_MINUTES_BEFORE until delivery_time
        window_start = delivery_datetime - SETUP_MINUTES_BEFORE.minutes
        now >= window_start && now < delivery_datetime
      end
    end
  end
end
