# frozen_string_literal: true

module RulerArea
  class ApplicationController < ActionController::Base
    include Pagy::Backend

    before_action :authenticate!

    def authenticate!
      redirect_to ruler_area_login_path unless signed_in?
    end

    def current_ruler
      @current_ruler ||= Ruler.find_by(id: session[:current_ruler_id])
    end

    def signed_in?
      current_ruler.present?
    end

    def root
      redirect_to ruler_area_tenants_path
    end
  end
end
