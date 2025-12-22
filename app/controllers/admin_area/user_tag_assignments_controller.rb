# typed: true
# frozen_string_literal: true

module AdminArea
  class UserTagAssignmentsController < AdminArea::ApplicationController
    require_feature :user_tag
    before_action :set_user
    before_action :set_user_tag, only: [:create, :destroy]

    def edit
      # Load all assignments once with includes (for tooltip display)
      all_assignments = @user.tag_assignments.includes(:user_tag, :user_auto_tagging).to_a

      @auto_assignments = all_assignments.select(&:auto?)
      @manual_assignments = all_assignments.reject(&:auto?)

      @all_tag_ids = all_assignments.map(&:user_tag_id)
      @available_tags = UserTag.order(:name)
      render_with_ui_toggle(:edit)
    end

    def create
      # Check if already assigned
      existing = @user.tag_assignments.find_by(user_tag: @user_tag)
      if existing
        render json: { error: 'タグは既に割り当てられています' }, status: :unprocessable_entity
        return
      end

      transaction_time = Time.zone.now

      ActiveRecord::Base.transaction do
        UserTagAssignment.create!(
          user: @user,
          user_tag: @user_tag,
          assignment_type: 'manual',
          assigned_by: current_admin,
          assigned_at: transaction_time,
        )

        UserEvent.record!(
          user: @user,
          event: UserEvent::Type::ManuallyTagged.new(
            tag_id: @user_tag.id,
            tagged_by: T.must(current_admin).id,
          ),
          transaction_time: transaction_time,
        )
      end

      render json: { success: true, message: 'タグを追加しました' }
    end

    def destroy
      assignment = @user.tag_assignments.manual.find_by(user_tag: @user_tag)

      unless assignment
        render json: { error: 'タグが見つかりません' }, status: :not_found
        return
      end

      transaction_time = Time.zone.now

      ActiveRecord::Base.transaction do
        assignment.destroy!

        UserEvent.record!(
          user: @user,
          event: UserEvent::Type::ManuallyUntagged.new(
            tag_id: @user_tag.id,
            untagged_by: T.must(current_admin).id,
          ),
          transaction_time: transaction_time,
        )
      end

      render json: { success: true, message: 'タグを削除しました' }
    end

    def tag_history
      render partial: 'tag_history', locals: { user: @user }
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_user_tag
      @user_tag = UserTag.find(params[:tag_id])
    end
  end
end
