Rails.application.routes.draw do
  scope module: :tenants_area do
    resources :sessions, only: [:new, :create, :destroy]

    namespace :api do
      namespace :private do
        resources :userinfo, only: [:index]
      end
    end
  end
end
