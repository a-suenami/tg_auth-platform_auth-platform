# typed: true
# frozen_string_literal: true

module AdminArea
  class UserTagAssignmentsController < AdminArea::ApplicationController
    before_action :set_user

    def edit
      # Load all assignments once with includes
      all_assignments = @user.tag_assignments.includes(:user_tag, :user_auto_tagging).to_a

      @auto_assignments = all_assignments.select(&:auto?)
      @manual_assignments = all_assignments.reject(&:auto?)

      @all_tag_ids = all_assignments.map(&:user_tag_id)
      @available_tags = UserTag.order(:name)
    end

    def update
      # Get selected tag IDs from params (manual tags only)
      selected_tag_ids = (params[:tag_ids] || []).compact_blank.map(&:to_s)

      # Get current MANUAL tag assignments only (auto tags are read-only)
      current_manual_assignments = @user.tag_assignments.manual.includes(:user_tag).to_a
      current_manual_tag_ids = current_manual_assignments.map { |a| a.user_tag_id.to_s }

      # Tags to add (newly selected manual tags)
      tags_to_add = selected_tag_ids - current_manual_tag_ids

      # Tags to remove (unchecked manual tags only - never remove auto tags)
      tags_to_remove = current_manual_tag_ids - selected_tag_ids

      # Wrap in transaction to ensure atomicity
      ActiveRecord::Base.transaction do
        transaction_time = Time.zone.now

        # Add new tags (as manual)
        tags_to_add.each do |tag_id|
          UserTagAssignment.create!(
            user: @user,
            user_tag_id: tag_id,
            assignment_type: 'manual',
            assigned_by: current_admin,
            assigned_at: transaction_time,
          )

          # Record event
          UserEvent.record!(
            user: @user,
            event: UserEvent::Type::ManuallyTagged.new(
              tag_id: tag_id,
              tagged_by: T.must(current_admin).id,
            ),
            transaction_time: transaction_time,
          )
        end

        # Remove unchecked manual tags only
        tags_to_remove.each do |tag_id|
          assignment = current_manual_assignments.find { |a| a.user_tag_id.to_s == tag_id }
          next unless assignment

          assignment.destroy!

          # Record event - always ManuallyUntagged since admin is performing the action
          UserEvent.record!(
            user: @user,
            event: UserEvent::Type::ManuallyUntagged.new(
              tag_id: tag_id,
              untagged_by: T.must(current_admin).id,
            ),
            transaction_time: transaction_time,
          )
        end
      end

      redirect_to admin_area_user_path(@user), notice: 'ユーザタグを更新しました'
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end
