Rails.application.routes.draw do
  namespace :user_area, path: :user do
    # root to: 'application#root', as: :root
    resources :sessions, only: [:new, :create, :destroy]
  end
end
