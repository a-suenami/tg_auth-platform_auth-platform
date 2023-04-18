Rails.application.routes.draw do
  namespace :admin_area, path: :admin do
    root to: 'application#root', as: :root

    get 'login', to: 'sessions#new', as: :login
    post 'login', to: 'sessions#create'
    get 'logout', to: 'sessions#destroy', as: :logout

    resources :users, only: %i[index show]
  end
end
