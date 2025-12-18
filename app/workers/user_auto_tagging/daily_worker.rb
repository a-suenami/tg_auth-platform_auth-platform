# typed: strict

class UserAutoTagging
  # Daily worker to re-evaluate time-based auto-tagging rules
  #
  # Some rules depend on time:
  # - AgeRule: User's age changes daily (birthday)
  # - MembershipDurationRule: Duration since joining changes daily
  # - PlanDurationRule: Duration since joining changes daily
  #
  # This worker runs daily to re-evaluate these rules for all users.
  #
  # @example Run via scheduler (3:00 AM daily)
  #   UserAutoTagging::DailyWorker.perform_async
  #
  class DailyWorker
    include Sidekiq::Worker
    include Sidekiq::Job
    extend T::Sig

    sidekiq_options queue: :low, retry: 1

    sig { void }
    def perform
      # Process each tenant separately
      Tenant.find_each do |tenant|
        process_tenant(tenant)
      end
    end

    private

    sig { params(tenant: Tenant).void }
    def process_tenant(tenant)
      # Set tenant context
      Tenant.current_domain = T.must(tenant.domain)

      # Find all active rules that have time-based events
      time_based_rules = UserAutoTagging
        .where(tenant_id: tenant.id)
        .enabled
        .includes(:schedule, :auto_tagging_tags, rule_blocks: :rules)
        .select do |rule|
          rule.active? && rule.events.include?(:new_day_arrived)
        end

      return if time_based_rules.empty?

      Rails.logger.info "DailyWorker: Tenant #{tenant.id} - Processing #{time_based_rules.count} time-based rules"

      # Apply each rule using the existing ApplyWorker (async)
      time_based_rules.each do |rule|
        UserAutoTagging::ApplyWorker.perform_async(rule.id)
      end
    end
  end
end
