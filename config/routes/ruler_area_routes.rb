Rails.application.routes.draw do
  namespace :ruler_area, path: :ruler do
    root to: 'application#root', as: :root

    get 'login', to: 'auth0#login'
    get 'logout', to: 'auth0#logout'
    get '/auth/auth0/callback' => 'auth0#callback'
    get '/auth/failure' => 'auth0#failure'
    get '/auth/logout' => 'auth0#logout'

    resources :rulers, only: [:index, :new, :create, :destroy]

    resources :tenants, only: [:index, :new, :create, :edit, :update] do
      get :admin_area, on: :member
      scope module: 'tenants' do
        get :root, to: 'application#root'
        resources :admins, only: [:index, :new, :create, :destroy]
        resources :login_spa_applications, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        resources :tenant_settings, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        resources :memberships, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
          get :top, on: :collection
        end
        resources :membership_plans, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        resources :shopify_multipass_stores, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        resources :email_templates, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        resources :oauth_applications, only: [:index, :show, :new, :create, :edit, :update, :destroy]
        namespace :stripe_records do
          resources :products, only: [:index, :show, :destroy] do
            post :preview, on: :collection
            put :sync, on: :collection
          end
        end
      end
    end
  end
end
