Rails.application.routes.draw do
  namespace :ruler_area, path: :ruler do
    root to: 'application#root', as: :root

    get 'login', to: 'auth0#login'
    get 'logout', to: 'auth0#logout'
    get '/auth/auth0/callback' => 'auth0#callback'
    get '/auth/failure' => 'auth0#failure'
    get '/auth/logout' => 'auth0#logout'

    resources :tenants, only: [:index, :new, :create, :edit, :update] do
      scope module: 'tenants' do
        get :root, to: 'application#root'
        resources :login_spa_applications, only: [:index, :show, :new, :create, :edit, :update, :destroy]
      end
    end
  end
end
