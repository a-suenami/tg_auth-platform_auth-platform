# typed: strict

class UserAutoTagging
  # Service to apply auto-tagging rules to all matching users
  #
  # Creates UserTagAssignments for matching users (all tags) and removes for non-matching
  # Records UserEvent for each tag assignment/removal
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

      # Get all tags linked to this auto-tagging
      tag_ids = user_auto_tagging.user_tag_ids
      return { added: 0, removed: 0 } if tag_ids.empty?

      transaction_time = Time.zone.now
      added_count = 0
      removed_count = 0

      ActiveRecord::Base.transaction do
        # Find matching users for this rule
        matching_users = user_auto_tagging.find_matching_users
        matching_user_ids = matching_users.pluck(:id)

        # Build expected pairs: each matching user should have ALL tags
        expected_pairs = Set.new
        matching_user_ids.each do |user_id|
          tag_ids.each do |tag_id|
            expected_pairs.add([user_id, tag_id])
          end
        end

        # Find ALL existing auto assignments for these tags (from any rule)
        all_auto_assignments = UserTagAssignment
          .auto
          .where(user_tag_id: tag_ids)

        all_auto_pairs = all_auto_assignments.pluck(:user_id, :user_tag_id).to_set

        # === ADDITION PHASE ===
        # Add new assignments (pairs in expected but not already assigned by anyone)
        pairs_to_add = expected_pairs - all_auto_pairs
        users_to_load = pairs_to_add.map(&:first).uniq
        users_by_id = User.where(id: users_to_load).index_by(&:id)

        pairs_to_add.each do |user_id, tag_id|
          UserTagAssignment.create!(
            tenant_id: user_auto_tagging.tenant_id,
            user_id: user_id,
            user_tag_id: tag_id,
            user_auto_tagging_id: user_auto_tagging.id,
            assignment_type: 'auto',
            assigned_at: transaction_time,
          )

          # Record event
          user = users_by_id[user_id]
          if user
            UserEvent.record!(
              user: user,
              event: UserEvent::Type::AutoTagged.new(
                tag_id: tag_id,
                auto_tagging_rule_id: user_auto_tagging.id,
              ),
              transaction_time: transaction_time,
            )
          end

          added_count += 1
        end

        # === REMOVAL PHASE ===
        # Find orphaned auto assignments for tags this rule cares about
        # (assignments where user no longer matches THIS rule)
        orphaned_pairs = all_auto_pairs - expected_pairs

        if orphaned_pairs.any?
          users_to_check = orphaned_pairs.map(&:first).uniq
          tags_to_check = orphaned_pairs.map(&:second).uniq
          users_by_id_for_remove = User.where(id: users_to_check).index_by(&:id)

          # Find ALL active auto-tagging rules that have these tags (including this one)
          all_rules_with_tags = UserAutoTagging
            .enabled
            .joins(:auto_tagging_tags)
            .where(user_auto_tagging_tags: { user_tag_id: tags_to_check })
            .distinct
            .includes(:auto_tagging_tags, rule_blocks: :rules)

          # Pre-compute which (user, tag) pairs are protected by ANY active rule
          protected_pairs = Set.new
          all_rules_with_tags.each do |rule|
            next unless rule.active?

            # Get matching users from this rule (scoped to users we're checking)
            rule_matching_ids = rule
              .find_matching_users(User.where(id: users_to_check))
              .pluck(:id)
              .to_set

            # Mark (user, tag) pairs as protected for tags this rule assigns
            rule.user_tag_ids.each do |rule_tag_id|
              next unless tags_to_check.include?(rule_tag_id)

              rule_matching_ids.each do |uid|
                protected_pairs.add([uid, rule_tag_id])
              end
            end
          end

          # Remove truly orphaned pairs (not protected by any rule)
          orphaned_pairs.each do |user_id, tag_id|
            next if protected_pairs.include?([user_id, tag_id])

            # Find and destroy the assignment (regardless of which rule created it)
            assignment = all_auto_assignments.find_by(user_id: user_id, user_tag_id: tag_id)
            next unless assignment

            original_rule_id = assignment.user_auto_tagging_id
            assignment.destroy!

            # Record event
            user = users_by_id_for_remove[user_id]
            if user
              UserEvent.record!(
                user: user,
                event: UserEvent::Type::AutoUntagged.new(
                  tag_id: tag_id,
                  auto_tagging_rule_id: original_rule_id,
                ),
                transaction_time: transaction_time,
              )
            end

            removed_count += 1
          end
        end
      end

      Rails.logger.info "UserAutoTagging #{user_auto_tagging.id} applied: added #{added_count}, removed #{removed_count}"

      { added: added_count, removed: removed_count }
    end
  end
end
