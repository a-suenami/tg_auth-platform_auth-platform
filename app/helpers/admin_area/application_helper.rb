# frozen_string_literal: true

module AdminArea
  module ApplicationHelper
    include ::ApplicationHelper
    include Pagy::Frontend

    def uikit_flash
      flash.map do |key, message|
        [class_of(key), message]
      end
    end

    def pagy_app_nav(pagy)
      render partial: 'admin_area/pagy/nav', locals: { pagy: }
    end

    def pagy_t(key, opts = {})
      # pagyのi18nキーを確認して、prev/nextのテキストを日本語に変更し、SVGアイコンを追加
      case key.to_s
      when 'pagy.nav.prev', 'nav.prev'
        (render('shared/icons/icon-chevron-left') + ' 前へ').html_safe
      when 'pagy.nav.next', 'nav.next'
        ('次へ ' + render('shared/icons/icon-chevron-right')).html_safe
      else
        super(key, opts)
      end
    end

    def last_access_page
      cookies[:page]
    end

    # Display time in client's local timezone
    # Usage: <%= local_time(user.created_at) %>
    # Usage: <%= local_time(user.created_at, format: 'short') %>
    def local_time(time, format: 'short')
      return '-' if time.nil?

      # Output timestamp and let JavaScript handle formatting
      timestamp = time.to_i * 1000  # JavaScript uses milliseconds

      content_tag(:time,
        time.in_time_zone.strftime('%Y/%m/%d %H:%M'),  # Fallback for no-JS
        datetime: time.iso8601,
        data: {
          timestamp: timestamp,
          format: format,
        },
        class: 'js-local-time',)
    end

    private

    def class_of(key)
      # primary, success, warning or a danger
      case key.to_s
      when 'alert'
        'danger'
      when 'success'
        'success'
      else
        ''
      end
    end
  end
end
