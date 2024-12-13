# typed: strict
# frozen_string_literal: true

module RulerArea
  class ApplicationController < ActionController::Base
    extend T::Sig
    include Pagy::Backend

    before_action :authenticate!

    sig { void }
    def authenticate!
      redirect_to ruler_area_login_path unless signed_in?
    end

    sig { returns(T.nilable(Ruler)) }
    def current_ruler
      @current_ruler ||= T.let(Ruler.find_by(id: session[:current_ruler_id]), T.nilable(Ruler))
    end

    sig { returns(T::Boolean) }
    def signed_in?
      current_ruler.present?
    end

    sig { void }
    def root
      redirect_to ruler_area_tenants_path
    end
  end
end
