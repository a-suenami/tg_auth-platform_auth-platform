# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :authentication do
        resources :sessions, only: [:create] do
          post :logout, on: :collection
        end
        resources :registrations, only: [] do
          collection do
            post :send_verification_email
            post :verify_email
          end
        end
        resources :passwords, only: [:create]
        resources :password_resets, only: [:create] do
          collection do
            post :request, to: 'password_resets#reset_requests'
          end
        end
      end
    end
  end
end
