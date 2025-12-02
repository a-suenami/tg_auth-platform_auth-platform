# typed: strict

class UserAutoTagging
  # Service to apply auto-tagging rules to all matching users
  #
  # Creates UserTagAssignments for matching users and removes for non-matching.
  # Records UserEvent for each tag assignment/removal.
  #
  # @example
  #   service = UserAutoTagging::ApplyService.new
  #   result = service.execute(user_auto_tagging)
  #   result #=> { added: 10, removed: 5 }
  #
  class ApplyService < BaseService
    extend T::Sig

    sig { params(user_auto_tagging: ::UserAutoTagging).returns(T::Hash[Symbol, Integer]) }
    def execute(user_auto_tagging)
      return { added: 0, removed: 0 } unless user_auto_tagging.active?

      tag_ids = user_auto_tagging.user_tag_ids
      return { added: 0, removed: 0 } if tag_ids.empty?

      transaction_time = Time.zone.now
      added_count = 0
      removed_count = 0

      ActiveRecord::Base.transaction do
        expected_pairs = build_expected_pairs(user_auto_tagging, tag_ids)
        all_auto_assignments = UserTagAssignment.auto.where(user_tag_id: tag_ids)
        all_auto_pairs = all_auto_assignments.pluck(:user_id, :user_tag_id).to_set

        added_count = add_tag_assignments(
          user_auto_tagging, expected_pairs, all_auto_pairs, transaction_time,
        )
        removed_count = remove_orphaned_assignments(
          expected_pairs, all_auto_pairs, all_auto_assignments, transaction_time,
        )
      end

      Rails.logger.info "UserAutoTagging #{user_auto_tagging.id} applied: added #{added_count}, removed #{removed_count}"
      { added: added_count, removed: removed_count }
    end

    private

    sig do
      params(
        user_auto_tagging: ::UserAutoTagging,
        tag_ids: T::Array[String],
      ).returns(T::Set[[String, String]])
    end
    def build_expected_pairs(user_auto_tagging, tag_ids)
      matching_user_ids = user_auto_tagging.find_matching_users.pluck(:id)
      pairs = Set.new
      matching_user_ids.each do |user_id|
        tag_ids.each { |tag_id| pairs.add([user_id, tag_id]) }
      end
      pairs
    end

    sig do
      params(
        user_auto_tagging: ::UserAutoTagging,
        expected_pairs: T::Set[[String, String]],
        existing_pairs: T::Set[[String, String]],
        transaction_time: ActiveSupport::TimeWithZone,
      ).returns(Integer)
    end
    def add_tag_assignments(user_auto_tagging, expected_pairs, existing_pairs, transaction_time)
      pairs_to_add = expected_pairs - existing_pairs
      return 0 if pairs_to_add.empty?

      users_by_id = User.where(id: pairs_to_add.map(&:first).uniq).index_by(&:id)
      count = 0

      pairs_to_add.each do |user_id, tag_id|
        UserTagAssignment.create!(
          tenant_id: user_auto_tagging.tenant_id,
          user_id: user_id,
          user_tag_id: tag_id,
          user_auto_tagging_id: user_auto_tagging.id,
          assignment_type: 'auto',
          assigned_at: transaction_time,
        )

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

        count += 1
      end

      count
    end

    sig do
      params(
        expected_pairs: T::Set[[String, String]],
        existing_pairs: T::Set[[String, String]],
        all_auto_assignments: T.untyped,
        transaction_time: ActiveSupport::TimeWithZone,
      ).returns(Integer)
    end
    def remove_orphaned_assignments(expected_pairs, existing_pairs, all_auto_assignments, transaction_time)
      orphaned_pairs = existing_pairs - expected_pairs
      return 0 if orphaned_pairs.empty?

      users_to_check = orphaned_pairs.map(&:first).compact.uniq
      tags_to_check = orphaned_pairs.map(&:second).compact.uniq
      users_by_id = User.where(id: users_to_check).index_by(&:id)
      protected_pairs = find_protected_pairs(users_to_check, tags_to_check)

      count = 0
      orphaned_pairs.each do |user_id, tag_id|
        next if protected_pairs.include?([user_id, tag_id])

        assignment = all_auto_assignments.find_by(user_id: user_id, user_tag_id: tag_id)
        next unless assignment

        original_rule_id = assignment.user_auto_tagging_id
        assignment.destroy!

        user = users_by_id[user_id]
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

        count += 1
      end

      count
    end

    sig { params(users_to_check: T::Array[String], tags_to_check: T::Array[String]).returns(T::Set[[String, String]]) }
    def find_protected_pairs(users_to_check, tags_to_check)
      protected_set = Set.new

      ::UserAutoTagging
        .enabled
        .joins(:auto_tagging_tags)
        .where(user_auto_tagging_tags: { user_tag_id: tags_to_check })
        .distinct
        .includes(:auto_tagging_tags, rule_blocks: :rules)
        .find_each do |rule|
          next unless rule.active?

          matching_ids = rule.find_matching_users(User.where(id: users_to_check)).pluck(:id).to_set
          rule.user_tag_ids.each do |rule_tag_id|
            next unless tags_to_check.include?(rule_tag_id)

            matching_ids.each { |uid| protected_set.add([uid, rule_tag_id]) }
          end
        end

      protected_set
    end
  end
end
