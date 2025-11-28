# typed: strict

class UserAutoTagging
  # Service to apply auto-tagging rules to all matching users
  #
  # Creates UserTagAssignments for matching users and removes for non-matching
  #
  # @example
  #   service = UserAutoTagging::ApplyService.new
  #   result = service.execute(user_auto_tagging)
  #   result #=> { added: 10, removed: 5 }
  #
  class ApplyService < BaseService
    extend T::Sig

    # Apply auto-tagging rule to all users
    #
    # @param user_auto_tagging [UserAutoTagging] The auto-tagging rule to apply
    # @return [Hash] Summary of changes { added: Integer, removed: Integer }
    sig { params(user_auto_tagging: ::UserAutoTagging).returns(T::Hash[Symbol, Integer]) }
    def execute(user_auto_tagging)
      return { added: 0, removed: 0 } unless user_auto_tagging.active?

      transaction_time = Time.zone.now
      added_count = 0
      removed_count = T.let(0, T.untyped)

      ActiveRecord::Base.transaction do
        # Find currently assigned users
        current_assignments = UserTagAssignment.where(user_auto_tagging_id: user_auto_tagging.id)
        current_user_ids = current_assignments.pluck(:user_id)

        # Find matching users (User.all already scoped by Multitenancy)
        matching_users = user_auto_tagging.find_matching_users
        matching_user_ids = matching_users.pluck(:id)

        # Add new assignments
        users_to_add = matching_user_ids - current_user_ids
        users_to_add.each do |user_id|
          UserTagAssignment.create!(
            tenant_id: user_auto_tagging.tenant_id,
            user_id: user_id,
            user_auto_tagging_id: user_auto_tagging.id,
            assignment_type: 'auto',
            assigned_at: transaction_time,
          )
          added_count += 1
        end

        # Remove old assignments
        users_to_remove = current_user_ids - matching_user_ids
        current_assignments.where(user_id: users_to_remove).destroy_all
        removed_count = users_to_remove.size
      end

      Rails.logger.info "UserAutoTagging #{user_auto_tagging.id} applied: added #{added_count}, removed #{removed_count}"

      { added: added_count, removed: removed_count }
    end
  end
end
