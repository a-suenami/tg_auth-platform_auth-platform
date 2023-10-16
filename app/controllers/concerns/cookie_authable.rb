module CookieAuthable
  extend ActiveSupport::Concern

  included do
    before_action :session_authenticate
    if respond_to?(:helper_method)
      helper_method :current_user
    end
  end

  def session_authenticate
    raise Exceptions::Auth::AuthError if cookie_session[:current_user_id].blank?

    @current_user = User.active.find cookie_session[:current_user_id]
  end

  def current_user
    @current_user ||= session_authenticate
  end
end
