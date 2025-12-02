# typed: strict
# frozen_string_literal: true

module UserTagAssignment
  class BulkUpdateService
    extend T::Sig

    sig { params(user: User, selected_tag_ids: T::Array[String], admin: Admin).void }
    def initialize(user:, selected_tag_ids:, admin:)
      @user = user
      @selected_tag_ids = selected_tag_ids
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        transaction_time = Time.zone.now

        add_new_tags(transaction_time)
        remove_unchecked_tags(transaction_time)
      end

      { success: true }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, errors: e.record.errors }
    rescue ActiveRecord::RecordNotDestroyed => e
      { success: false, errors: e.record.errors }
    end

    sig { params(user: User, selected_tag_ids: T::Array[String], admin: Admin).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(user:, selected_tag_ids:, admin:)
      new(user: user, selected_tag_ids: selected_tag_ids, admin: admin).call
    end

    private

    sig { returns(T::Array[::UserTagAssignment]) }
    def current_manual_assignments
      @current_manual_assignments ||= T.let(
        @user.tag_assignments.manual.includes(:user_tag).to_a,
        T.nilable(T::Array[::UserTagAssignment])
      )
    end

    sig { returns(T::Array[String]) }
    def current_manual_tag_ids
      @current_manual_tag_ids ||= T.let(
        current_manual_assignments.map { |a| a.user_tag_id.to_s },
        T.nilable(T::Array[String])
      )
    end

    sig { returns(T::Array[String]) }
    def tags_to_add
      @selected_tag_ids - current_manual_tag_ids
    end

    sig { returns(T::Array[String]) }
    def tags_to_remove
      current_manual_tag_ids - @selected_tag_ids
    end

    sig { params(transaction_time: ActiveSupport::TimeWithZone).void }
    def add_new_tags(transaction_time)
      tags_to_add.each do |tag_id|
        ::UserTagAssignment.create!(
          user: @user,
          user_tag_id: tag_id,
          assignment_type: 'manual',
          assigned_by: @admin,
          assigned_at: transaction_time,
        )

        UserEvent.record!(
          user: @user,
          event: UserEvent::Type::ManuallyTagged.new(
            tag_id: tag_id,
            tagged_by: @admin.id,
          ),
          transaction_time: transaction_time,
        )
      end
    end

    sig { params(transaction_time: ActiveSupport::TimeWithZone).void }
    def remove_unchecked_tags(transaction_time)
      tags_to_remove.each do |tag_id|
        assignment = current_manual_assignments.find { |a| a.user_tag_id.to_s == tag_id }
        next unless assignment

        assignment.destroy!

        UserEvent.record!(
          user: @user,
          event: UserEvent::Type::ManuallyUntagged.new(
            tag_id: tag_id,
            untagged_by: @admin.id,
          ),
          transaction_time: transaction_time,
        )
      end
    end
  end
end
