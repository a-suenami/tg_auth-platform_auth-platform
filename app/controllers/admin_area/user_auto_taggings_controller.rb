# typed: true

module AdminArea
  class UserAutoTaggingsController < ApplicationController
    before_action :set_user_auto_tagging, only: [:edit, :update, :destroy]

    def index
      query = UserAutoTagging.ordered.search_by_name(params[:q])
      @pagy, @user_auto_taggings = pagy(query, items: 10)
    end

    def new
      @user_auto_tagging = UserAutoTagging.new
      @user_auto_tagging.build_schedule
      @user_tags = available_tags_for_selection
    end

    def tag_picker
      @user_tags = UserTag.ordered
    end

    def edit
      @user_tags = available_tags_for_selection(exclude_rule: @user_auto_tagging)
    end

    def create
      @user_auto_tagging = UserAutoTagging.new(user_auto_tagging_params)
      @user_auto_tagging.created_by = current_admin

      if @user_auto_tagging.save
        # Apply auto-tagging rules to all matching users
        apply_tagging_rules(@user_auto_tagging)

        redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を保存しました'
      else
        @user_tags = available_tags_for_selection
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user_auto_tagging.updated_by = current_admin

      if @user_auto_tagging.update(user_auto_tagging_params)
        # Apply auto-tagging rules to all matching users
        apply_tagging_rules(@user_auto_tagging)

        redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を更新しました'
      else
        @user_tags = available_tags_for_selection(exclude_rule: @user_auto_tagging)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Assignments will be automatically deleted via dependent: :destroy in model
      @user_auto_tagging.destroy!
      redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を削除しました', status: :see_other
    end

    private

    def set_user_auto_tagging
      @user_auto_tagging = UserAutoTagging.find(params[:id])
    end

    def apply_tagging_rules(user_auto_tagging)
      UserAutoTagging::ApplyWorker.perform_async(user_auto_tagging.id)
    end

    # Get tags available for selection (excluding tags already used by other rules)
    def available_tags_for_selection(exclude_rule: nil)
      used_tag_ids = UserAutoTaggingTag.pluck(:user_tag_id)

      # If editing, allow tags that are already assigned to this rule
      if exclude_rule
        current_rule_tag_ids = exclude_rule.user_tag_ids
        used_tag_ids -= current_rule_tag_ids
      end

      UserTag.where.not(id: used_tag_ids).ordered
    end

    def user_auto_tagging_params
      params.require(:user_auto_tagging).permit(
        :name,
        :description,
        :enabled,
        :shareable,
        schedule_attributes: [:id, :start_at, :end_at, :_destroy],
        rule_blocks_attributes: [
          :id,
          :position,
          :_destroy,
          rules_attributes: [:id, :condition_type, :position, :_destroy, :config],
        ],
        user_tag_ids: [],
      ).tap do |whitelisted|
        # Parse config JSON strings to hashes
        whitelisted[:rule_blocks_attributes]&.each_value do |block_attrs|
          next unless block_attrs[:rules_attributes]

          block_attrs[:rules_attributes].each_value do |rule_attrs|
            next unless rule_attrs[:config].is_a?(String)

            begin
              rule_attrs[:config] = JSON.parse(rule_attrs[:config])
            rescue JSON::ParserError
              rule_attrs[:config] = nil
            end
          end
        end
      end
    end
  end
end
