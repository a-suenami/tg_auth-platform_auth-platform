Rails.application.routes.draw do
  # format :html になるのを避けるため設定
  namespace :api, format: 'json' do
    namespace :v1 do
      namespace :private do
        resources :userinfo, only: [:index]
      end
    end
  end
end
