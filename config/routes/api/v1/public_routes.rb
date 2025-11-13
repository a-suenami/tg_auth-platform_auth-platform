# ==============================================================================
# config - routes - api - v1 - public routes
# ==============================================================================
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :public do
        resources :memberships, only: [:index, :show]

        resources :membership_plans, only: [:index, :show]

        resources :membership_groups, only: [:index, :show]

        resource :tenant_stripe_account, only: [:show], controller: 'tenant_stripe_accounts'
      end
    end
  end
end
