# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :authentication do
        resources :sessions, only: [:create] do
          get :logout, on: :collection
        end
        resources :registrations, only: [] do
          collection do
            post :send_verification_email
            post :verify_email
          end
        end
        resources :passwords, only: [:create]
        resources :profiles, only: [:create]
        resources :password_resets, only: [:create] do
          collection do
            put :update
          end
        end
      end
    end
  end
end
