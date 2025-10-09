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
          format: format
        },
        class: 'js-local-time'
      )
    end

    private

    def class_of(key)
      # primary, success, warning or a danger
      case key
      when 'notice'
        'primary'
      when 'alert'
        'danger'
      else
        ''
      end
    end
  end
end
