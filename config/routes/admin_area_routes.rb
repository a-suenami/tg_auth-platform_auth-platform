Rails.application.routes.draw do
  namespace :admin_area, path: :admin do
    root to: 'application#root', as: :root

    get 'login', to: 'auth0#login'
    get 'logout', to: 'auth0#logout'
    get '/auth/auth0/callback' => 'auth0#callback'
    get '/auth/failure' => 'auth0#failure'
    get '/auth/logout' => 'auth0#logout'

    resources :users, only: %i[index show edit update]
    resources :users, only: [] do
      resource :user_profile, only: [:new, :create, :edit, :update]
      resource :contact_address, only: [:new, :create, :edit, :update]
    end
  end
end
