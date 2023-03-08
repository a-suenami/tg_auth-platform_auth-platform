# ==============================================================================
# config - routes - api - v1 - public routes
# ==============================================================================
Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :public do
        # ...
      end
    end
  end
end
