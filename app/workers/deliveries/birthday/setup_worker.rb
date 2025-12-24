# typed: false

module Deliveries
  module Birthday
    # SetupWorker processes a single birthday delivery
    # Called by OrchestratorWorker with birthday_id and tenant_id
    #
    # Flow:
    # 1. OrchestratorWorker finds ongoing birthdays not yet setup today
    # 2. Enqueues this worker with (birthday_id, tenant_id)
    # 3. This worker checks setup window and calls SetupService
    class SetupWorker
      include Sidekiq::Worker
      include Concerns::TenantContext

      sidekiq_options queue: :default, retry: 3

      SETUP_MINUTES_BEFORE = 15

      def perform(birthday_id, tenant_id)
        set_tenant_context_by_id(tenant_id)

        Sentry.set_context('worker', {
          class: self.class.name,
          birthday_id: birthday_id,
        },)

        birthday = DeliveryBirthday.find_by(id: birthday_id)
        return unless birthday
        return unless birthday.ongoing? # Status guard: may have changed

        # Skip if already setup for today
        today = Date.current
        return if birthday.last_setup_date == today && birthday.setup_completed_at.present?

        # Skip if not within setup window (15 mins before delivery_time)
        return unless within_setup_window?(birthday.delivery_time)

        Rails.logger.info("[Birthday::SetupWorker] Processing birthday #{birthday_id}")

        result = Deliveries::Birthday::SetupService.new(birthday: birthday).execute

        if result[:success]
          Rails.logger.info("[Birthday::SetupWorker] #{birthday_id} setup complete: #{result[:users_count] || 0} users")
        else
          Rails.logger.error("[Birthday::SetupWorker] #{birthday_id} failed: #{result[:error]}")
          capture_soft_failure(
            '[Birthday::SetupWorker] Setup service failed',
            context: {
              birthday_id: birthday_id,
              delivery_id: birthday.delivery_id,
              delivery_time: birthday.delivery_time,
              error: result[:error],
            },
          )
        end
      rescue StandardError => e
        Rails.logger.error("[Birthday::SetupWorker] Error processing #{birthday_id}: #{e.message}")
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

      def within_setup_window?(delivery_time_string)
        now = Time.current
        hour, minute = delivery_time_string.split(':').map(&:to_i)
        delivery_datetime = Time.zone.local(now.year, now.month, now.day, hour, minute)

        window_start = delivery_datetime - SETUP_MINUTES_BEFORE.minutes
        now >= window_start && now < delivery_datetime
      end
    end
  end
end
