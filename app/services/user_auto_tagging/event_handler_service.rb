# typed: strict

class UserAutoTagging
  # Service to handle auto-tagging events for a single user
  #
  # When user data changes (profile, address, membership), this service:
  # 1. Finds all active rules that care about this event
  # 2. Checks if user matches each rule
  # 3. Adds/removes tag assignments accordingly
  #
  # @example Profile updated
  #   service = UserAutoTagging::EventHandlerService.new
  #   result = service.execute(user: user, event: :profile_updated)
  #   result #=> { added: 2, removed: 1 }
  #
  class EventHandlerService < BaseService
    extend T::Sig

    # Handle auto-tagging event for a user
    #
    # @param user [User] The user whose data changed
    # @param event [Symbol] The event type (:profile_updated, :address_changed, etc.)
    # @return [Hash] Summary of changes { added: Integer, removed: Integer }
    sig { params(user: User, event: Symbol).returns(T::Hash[Symbol, Integer]) }
    def execute(user:, event:)
      transaction_time = Time.zone.now
      added_count = 0
      removed_count = 0

      # Find all active rules that care about this event
      relevant_rules = find_relevant_rules(event)
      return { added: 0, removed: 0 } if relevant_rules.empty?

      ActiveRecord::Base.transaction do
        relevant_rules.each do |auto_tagging|
          # Get tags for this rule
          tag_ids = auto_tagging.user_tag_ids
          next if tag_ids.empty?

          # Check if user matches this rule
          user_matches = auto_tagging.match?(user.id)

          tag_ids.each do |tag_id|
            existing_assignment = user.tag_assignments.auto.find_by(user_tag_id: tag_id)

            if user_matches && existing_assignment.nil?
              # User matches and doesn't have tag → ADD
              UserTagAssignment.create!(
                tenant_id: user.tenant_id,
                user: user,
                user_tag_id: tag_id,
                user_auto_tagging: auto_tagging,
                assignment_type: 'auto',
                assigned_at: transaction_time,
              )

              UserEvent.record!(
                user: user,
                event: UserEvent::Type::AutoTagged.new(
                  tag_id: tag_id,
                  auto_tagging_rule_id: auto_tagging.id,
                ),
                transaction_time: transaction_time,
              )

              added_count += 1

            elsif !user_matches && existing_assignment.present?
              # User doesn't match and has auto tag → REMOVE
              # With unique tag constraint, this assignment must be from this rule
              existing_assignment.destroy!

              UserEvent.record!(
                user: user,
                event: UserEvent::Type::AutoUntagged.new(
                  tag_id: tag_id,
                  auto_tagging_rule_id: auto_tagging.id,
                ),
                transaction_time: transaction_time,
              )

              removed_count += 1
            end
          end
        end
      end

      Rails.logger.info "EventHandlerService for User #{user.id}, event #{event}: added #{added_count}, removed #{removed_count}"

      { added: added_count, removed: removed_count }
    end

    private

    # Find all active auto-tagging rules that respond to this event
    sig { params(event: Symbol).returns(T::Array[UserAutoTagging]) }
    def find_relevant_rules(event)
      UserAutoTagging.enabled.includes(:auto_tagging_tags, rule_blocks: :rules).select do |rule|
        rule.active? && rule.events.include?(event)
      end
    end
  end
end
