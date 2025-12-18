Rails.application.routes.draw do
  namespace :admin_area, path: :admin do
    root to: 'application#root', as: :root

    get 'login', to: 'auth0#login'
    get 'logout', to: 'auth0#logout'
    get '/auth/auth0/callback' => 'auth0#callback'
    get '/auth/failure' => 'auth0#failure'
    get '/auth/logout' => 'auth0#logout'

    resources :users, only: %i[index show edit update] do
      member do
        put :reset_sms_ratelimit
      end
      resource :user_profile, only: [:new, :create, :edit, :update]
      resource :contact_address, only: [:new, :create, :edit, :update]
      resources :user_tag_assignments, only: [:edit, :create, :destroy], path: 'tags', param: :tag_id do
        collection do
          get '', action: :edit, as: ''
          get 'history', action: :tag_history
        end
      end
    end

    resources :templates, except: [:edit, :destroy] do
      resource :mail, only: [:edit, :update], controller: 'templates/mail' do
        post :publish, on: :member
        post :schedule, on: :member
        post :cancel, on: :member
        post :preview, on: :member
      end
    end

    # User Tag Management
    resources :user_tags
    resources :user_auto_taggings

    # Delivery Management
    resources :deliveries do
      member do
        post :publish   # draft → scheduled
        post :cancel    # scheduled → cancelled (datetime only)
        post :pause     # scheduled → paused (birthday only)
        post :resume    # paused → scheduled (birthday only)
      end
    end
  end
end
