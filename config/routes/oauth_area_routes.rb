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
  end
end
