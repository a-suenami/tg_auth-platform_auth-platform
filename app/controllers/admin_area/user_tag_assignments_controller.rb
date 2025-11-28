# typed: true
# frozen_string_literal: true

module AdminArea
  class UserTagAssignmentsController < AdminArea::ApplicationController
    before_action :set_user

    def edit
      @available_tags = UserTag.order(:name)

      # Load all assignments once and cache for view
      assignments = @user.tag_assignments.to_a
      @all_tag_ids = assignments.map(&:user_tag_id)
      @auto_tag_ids = assignments.select(&:auto?).map(&:user_tag_id)
      @manual_tag_ids = @all_tag_ids - @auto_tag_ids
    end

    def update
      # Get selected tag IDs from params
      selected_tag_ids = (params[:tag_ids] || []).compact_blank.map(&:to_s)

      # Get current manual tag assignments
      current_assignments = @user.tag_assignments.manual.includes(:user_tag)
      current_manual_tag_ids = current_assignments.pluck(:user_tag_id).map(&:to_s)

      # Tags to add (newly selected)
      tags_to_add = selected_tag_ids - current_manual_tag_ids

      # Tags to remove (unchecked manual tags)
      tags_to_remove = current_manual_tag_ids - selected_tag_ids

      # Wrap in transaction to ensure atomicity
      ActiveRecord::Base.transaction do
        transaction_time = Time.zone.now

        # Add new tags
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
              tagged_by: current_admin.id,
            ),
            transaction_time: transaction_time,
          )
        end

        # Remove unchecked tags (only manual ones)
        tags_to_remove.each do |tag_id|
          assignment = current_assignments.find { |a| a.user_tag_id.to_s == tag_id }
          if assignment
            assignment.destroy!

            # Record event
            UserEvent.record!(
              user: @user,
              event: UserEvent::Type::ManuallyUntagged.new(
                tag_id: tag_id,
                untagged_by: current_admin.id,
              ),
              transaction_time: transaction_time,
            )
          end
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
