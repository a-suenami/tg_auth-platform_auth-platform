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
      end
    end
  end
end
