Rails.application.routes.draw do
  namespace :admin_area, path: :admin do
    root to: 'application#root', as: :root
  end
end
