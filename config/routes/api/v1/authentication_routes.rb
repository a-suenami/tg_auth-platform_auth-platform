# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :authentication do
        resources :sessions, only: [:create]
        post :logout, to: 'logout#create'
        resources :registrations, only: [] do
          collection do
            post :send_verification_email
            post :verify_email
          end
        end
        resources :sms_verify, only: [] do
          collection do
            post :send_verification_sms
            post :verify_sms
          end
        end
        resources :sms_two_factor_authenticate, only: [] do
          collection do
            post :send_authentication_sms
            post :authenticate_sms
          end
        end
        resource :passwords, only: [:create, :update]
        resources :password_resets, only: [:create] do
          collection do
            post :request, to: 'password_resets#reset_requests'
          end
        end
      end
    end
  end
end
