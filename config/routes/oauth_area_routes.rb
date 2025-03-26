Rails.application.routes.draw do
  scope module: :oauth_area do
    resources :authorizations, only: [] do
      collection do
        get :relaunch
      end
    end
    resources :account_locks, only: [] do
      collection do
        get :unlock
      end
    end
    resources :sessions, only: [] do
      collection do
        get :logout
      end
    end

    resources :federated_authentications, only: [] do
      collection do
        get 'oauth/redirect/:provider', to: 'federated_authentications#redirect', as: :oauth_redirect
        get 'oauth/callback', to: 'federated_authentications#callback', as: :oauth_callback
      end
    end
  end
end
