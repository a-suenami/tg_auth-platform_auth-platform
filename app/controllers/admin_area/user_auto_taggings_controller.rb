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
    end

    def edit
    end

    def create
      @user_auto_tagging = UserAutoTagging.new(user_auto_tagging_params)
      @user_auto_tagging.created_by = current_admin

      if @user_auto_tagging.save
        redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を保存しました'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def update
      @user_auto_tagging.updated_by = current_admin

      if @user_auto_tagging.update(user_auto_tagging_params)
        redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を更新しました'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @user_auto_tagging.destroy!
      redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を削除しました', status: :see_other
    end

    private

    def set_user_auto_tagging
      @user_auto_tagging = UserAutoTagging.find(params[:id])
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
