# frozen_string_literal: true

module RulerArea
  module ApplicationHelper
    include ::ApplicationHelper
    include Pagy::Frontend

    def uikit_flash
      flash.map do |key, message|
        [class_of(key), message]
      end
    end

    def pagy_app_nav(pagy)
      render partial: 'ruler_area/pagy/nav', locals: { pagy: }
    end

    def last_access_page
      cookies[:page]
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
