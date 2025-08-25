# ==============================================================================
# config - routes - api - v1 - public routes
# ==============================================================================
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :public do
        resources :memberships, only: [:index, :show] do
          collection do
            get :by_group
          end
        end

        resources :membership_plans, only: [:index, :show]

        resources :membership_groups, only: [:index, :show]
      end
    end
  end
end
