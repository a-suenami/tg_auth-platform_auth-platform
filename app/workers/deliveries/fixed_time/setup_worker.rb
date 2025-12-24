# typed: false

module Deliveries
  module FixedTime
    # SetupWorker processes a single scheduled delivery
    # Called by OrchestratorWorker with schedule_id and tenant_id
    #
    # Flow:
    # 1. OrchestratorWorker finds scheduled deliveries due for setup
    # 2. Enqueues this worker with (schedule_id, tenant_id)
    # 3. This worker sets tenant context and calls SetupService
    class SetupWorker
      include Sidekiq::Worker
      include Concerns::TenantContext

      sidekiq_options queue: :default, retry: 3, unique_for: 5.minutes

      def perform(schedule_id, tenant_id)
        set_tenant_context_by_id(tenant_id)

        Sentry.set_context('worker', {
          class: self.class.name,
          schedule_id: schedule_id,
        },)

        schedule = DeliverySchedule.find_by(id: schedule_id)
        return unless schedule
        return unless schedule.scheduled? # Status guard: may have changed

        Rails.logger.info("[FixedTime::SetupWorker] Processing schedule #{schedule_id}")

        result = Deliveries::FixedTime::SetupService.new(schedule: schedule).execute

        if result[:success]
          Rails.logger.info("[FixedTime::SetupWorker] #{schedule_id} setup complete")
        else
          Rails.logger.error("[FixedTime::SetupWorker] #{schedule_id} failed: #{result[:error]}")
          capture_soft_failure(
            '[FixedTime::SetupWorker] Setup service failed',
            context: {
              schedule_id: schedule_id,
              delivery_id: schedule.delivery_id,
              error: result[:error],
            },
          )
        end
      rescue StandardError => e
        Rails.logger.error("[FixedTime::SetupWorker] Error processing #{schedule_id}: #{e.message}")
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
    end
  end
end
