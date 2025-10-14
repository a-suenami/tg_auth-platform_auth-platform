# typed: false

module AdminArea
  class UserTagsController < ApplicationController
    MockUserTag = Struct.new(:id, :name, :description, :created_by, :created_at, :updated_by, :updated_at, keyword_init: true)
    MockPagination = Struct.new(:page, :total_count, :pages, :items, :from, :to, :prev, :next, keyword_init: true)

    def index
      @user_tags = mock_user_tags
      @pagy = mock_pagination
    end

    def show
    end

    def new
      @user_tag = MockUserTag.new(name: '', description: '')
    end

    def edit
      # Mock find tag by ID
      @user_tag = mock_find_user_tag(params[:id])
    end

    def create
      # Mock creation - just redirect with flash
      redirect_to admin_area_user_tags_path, notice: 'タグを作成しました'
    end


    def update
      # Mock update - just redirect with flash
      redirect_to admin_area_user_tags_path, notice: 'タグを更新しました'
    end

    def destroy
      # Mock deletion - just redirect with flash
      redirect_to admin_area_user_tags_path, notice: 'タグを削除しました', status: :see_other
    end

    private

    def mock_user_tags
      [
        {
          id: 1, name: 'ユーザー手動タグ1', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 10.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: 5.days.ago.strftime('%Y/%m/%d %H:%M'),
        },
        {
          id: 2, name: 'ユーザー手動タグ2', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 9.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: 4.days.ago.strftime('%Y/%m/%d %H:%M'),
        },
        {
          id: 3, name: 'ユーザー手動タグ3', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 8.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: 3.days.ago.strftime('%Y/%m/%d %H:%M'),
        },
        {
          id: 4, name: 'ユーザー手動タグ4', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 7.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: 2.days.ago.strftime('%Y/%m/%d %H:%M'),
        },
        {
          id: 5, name: 'ユーザー手動タグ5', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 6.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: 1.day.ago.strftime('%Y/%m/%d %H:%M'),
        },
        {
          id: 6, name: 'ユーザー手動タグ6', description: '手動タグです手動タグです', created_by: 'YamadaTARO', created_at: 5.days.ago.strftime('%Y/%m/%d %H:%M'), updated_by: 'YamadaTARO',
          updated_at: Time.current.strftime('%Y/%m/%d %H:%M'),
        },
      ].map { |tag| MockUserTag.new(**tag) }
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

    def mock_find_user_tag(id)
      mock_user_tags.find { |t| t.id == id.to_i }
    end
  end
end
