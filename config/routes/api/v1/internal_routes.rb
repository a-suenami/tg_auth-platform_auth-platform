# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :internal do
        get :me, to: 'me#show'
        delete :me, to: 'me#destroy'
        namespace :me do
          resource :profile, only: [:show, :update]
          resources :delivery_addresses, only: [:show, :index, :create, :update, :destroy]
          resource :card, only: [:show, :update, :destroy] do
            member do
              post :setup_intent, action: :create_setup_intent
            end
          end
        end

        resource :email_change, only: [:create] do
          post :request, to: 'email_changes#email_change_request'
        end

        namespace :memberships do
          resources :user_contracts, only: [] do
            member do
              get :plan_change_preview, to: 'user_contracts/plan_change#preview'
              post :plan_change, to: 'user_contracts/plan_change#create'
              post :cancel, to: 'user_contracts#cancel'
            end
          end
          namespace :user_contracts do
            resources :credit_card_payments, only: [:create]
          end
        end
      end
    end
  end
end
