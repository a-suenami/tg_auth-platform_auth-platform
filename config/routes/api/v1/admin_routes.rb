# ==============================================================================
# config - routes - api - v1 - admin routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :admin do
        resources :users, only: [:show]
      end
    end
  end
end
