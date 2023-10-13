module DoorkeeperAuthable
  extend ActiveSupport::Concern

  included do
    if respond_to?(:helper_method)
      helper_method :current_user
    end
  end

  def current_user
    raise Exceptions::Auth::AccessTokenExpired if doorkeeper_token.expired?

    @current_user ||= User.active.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
