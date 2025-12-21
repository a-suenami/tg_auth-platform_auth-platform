# typed: true

module AdminArea
  class UserTagsController < ApplicationController
    before_action :set_user_tag, only: [:edit, :update, :destroy]

    def index
      query = UserTag.ordered.search_by_name(params[:q])
      @pagy, @user_tags = pagy(query, items: 10)
      render_with_ui_toggle(:index)
    end

    def new
      @user_tag = UserTag.new
      render_with_ui_toggle(:new)
    end

    def edit
      render_with_ui_toggle(:edit)
    end

    def create
      @user_tag = UserTag.new(user_tag_params)
      @user_tag.created_by = current_admin

      if @user_tag.save
        redirect_to admin_area_user_tags_path, notice: 'タグを作成しました'
      else
        render_with_ui_toggle(:new, status: :unprocessable_entity)
      end
    end

    def update
      @user_tag.updated_by = current_admin

      if @user_tag.update(user_tag_params)
        redirect_to admin_area_user_tags_path, notice: 'タグを更新しました'
      else
        render_with_ui_toggle(:edit, status: :unprocessable_entity)
      end
    end

    def destroy
      if @user_tag.destroy
        redirect_to admin_area_user_tags_path, notice: 'タグを削除しました', status: :see_other
      else
        redirect_to admin_area_user_tags_path, alert: 'このタグは配信イベントで使用されているため削除できません', status: :see_other
      end
    end

    private

    def set_user_tag
      @user_tag = UserTag.find(params[:id])
    end

    def user_tag_params
      params.require(:user_tag).permit(:name, :description)
    end
  end
end
