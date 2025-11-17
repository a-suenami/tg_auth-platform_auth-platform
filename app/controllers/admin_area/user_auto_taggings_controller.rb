# typed: false

module AdminArea
  class UserAutoTaggingsController < ApplicationController
    MockPagination = Struct.new(:page, :total_count, :pages, :items, :from, :to, :prev, :next, keyword_init: true)
    MockUserAutoTagging = Struct.new(:id, :name, :description, :created_by, :created_at, :updated_by, :updated_at, keyword_init: true)

    def index
      @user_auto_taggings = mock_user_auto_taggings
      @pagy = mock_pagination
    end

    def show
    end

    def new
      @user_auto_tagging = MockUserAutoTagging.new(name: '', description: '')
    end

    def edit
      @user_auto_tagging = MockUserAutoTagging.new(
        id: params[:id],
        name: "オートタグルール#{params[:id]}",
        description: 'Mock description',
      )
    end

    def create
      redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を保存しました'
    end


    def update
      redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を更新しました'
    end

    def destroy
      redirect_to admin_area_user_auto_taggings_path, notice: 'オートタグ設定を削除しました', status: :see_other
    end

    private

    def mock_user_auto_taggings
      [
        { id: 1, name: '三ヶ月以内に Membership Aを購読したユーザー', created_by: 'Yamada TARO' },
        { id: 2, name: '2025/10/01 00:00 - 2025/10/31 23:59に何かのプランを購読したユーザー', created_by: 'Yamada TARO' },
        { id: 3, name: '一年間 Membership Aか上を購読しているユーザー', created_by: 'Yamada TARO' },
        { id: 4, name: 'Membership AかつMembershipB購読しているユーザー', created_by: 'Yamada TARO' },
        { id: 5, name: 'Membership AもしくはMembership B購読しているユーザー', created_by: 'Yamada TARO' },
        { id: 6, name: 'e.g. キャンペーンA期間登録', created_by: 'Yamada TARO' },
        { id: 7, name: 'e.g. Line連携済み', created_by: 'Yamada TARO' },
        { id: 8, name: 'e.g. Membership A購読 + Line連携済み', created_by: 'Yamada TARO' },
        { id: 9, name: 'e.g. Annual MembershipA', created_by: 'Yamada TARO' },
      ].map  { |tag| MockUserAutoTagging.new(**tag) }
    end

    def mock_pagination
      MockPagination.new(
        page: 1,
        total_count: 999,
        pages: 20,
        items: 50,
        from: 1,
        to: 50,
        prev: nil,
        next: 2,
      )
    end
  end
end
