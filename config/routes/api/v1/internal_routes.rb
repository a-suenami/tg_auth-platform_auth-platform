# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :internal do
        get :me, to: 'me#show'
        namespace :me do
          resource :profile, only: [:show, :create, :update]
          resources :delivery_addresses, only: [:show, :index, :create, :update, :destroy]
        end

        resource :email_change, only: [:create] do
          post :request, to: 'email_changes#email_change_request'
        end
      end
    end
  end
end
