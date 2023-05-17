Rails.application.routes.draw do
  scope module: :tenants_area do
    resources :sessions, only: [:new, :create, :destroy]
    resources :registrations, only: [:new] do
      collection do
        post :send_verification_email
        post :verify_email
      end
    end
    resources :passwords, only: [:new, :create]
    resources :profiles, only: [:new, :create]
    resources :password_resets, only: [:new, :create] do
      collection do
        get :edit
        put :update
      end
    end
  end
end
