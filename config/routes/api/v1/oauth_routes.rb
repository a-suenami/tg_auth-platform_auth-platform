# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :oauth do
        post :login
        get :logout
        post :signup
      end
    end
  end
end
