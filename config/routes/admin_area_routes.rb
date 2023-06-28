Rails.application.routes.draw do
  namespace :admin_area, path: :admin do
    root to: 'application#root', as: :root

    get 'login', to: 'auth0#login'
    get 'logout', to: 'auth0#logout'
    get '/auth/auth0/callback' => 'auth0#callback'
    get '/auth/failure' => 'auth0#failure'
    get '/auth/logout' => 'auth0#logout'

    resources :users, only: %i[index show]
    resources :email_templates, only: [:index, :show, :new, :create, :edit, :update, :destroy]
    resources :oauth_applications, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  end
end
