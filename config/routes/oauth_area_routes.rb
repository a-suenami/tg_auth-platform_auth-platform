Rails.application.routes.draw do
  scope module: :oauth_area do
    resources :authorizations, only: [] do
      collection do
        get :relaunch
      end
    end
  end
end
