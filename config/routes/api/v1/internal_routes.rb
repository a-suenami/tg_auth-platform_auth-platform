# ==============================================================================
# config - routes - api - v1 - oauth routes
# ==============================================================================
Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :internal do
        resource :me, only: [:show]
        namespace :me do
          resource :profile, only: [:show, :create, :update]
        end
      end
    end
  end
end
