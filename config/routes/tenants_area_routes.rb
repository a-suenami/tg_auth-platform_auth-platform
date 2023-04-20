Rails.application.routes.draw do
  scope module: :tenants_area do
    resources :sessions, only: [:new, :create, :destroy]

    # format :html になるのを避けるため設定
    namespace :api, format: 'json' do
      namespace :oauth do
        post :login
        get :logout
      end
      resource :oauth do
      end
      namespace :private do
        resources :userinfo, only: [:index]
      end
    end
  end
end
