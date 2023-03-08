Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :private do
        # ...
      end
    end
  end
end
