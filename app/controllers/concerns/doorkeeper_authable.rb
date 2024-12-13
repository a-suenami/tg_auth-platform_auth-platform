# typed: strict

module DoorkeeperAuthable
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { Kernel }
  requires_ancestor { Doorkeeper::Rails::Helpers }

  included do
    if respond_to?(:helper_method)
      T.bind(self, AbstractController::Helpers::ClassMethods)
      helper_method :current_user
    end

  end

  sig { returns(User) }
  def current_user
    raise Exceptions::Auth::AccessTokenExpired if doorkeeper_token.expired?

    @current_user = T.let(nil, T.nilable(User))
    @current_user ||= User.active.find(doorkeeper_token.resource_owner_id) if doorkeeper_token
  end
end
