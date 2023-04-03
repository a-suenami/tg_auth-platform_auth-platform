Rails.application.routes.draw do
  scope module: :tenants_area do
    namespace :sample_area, path: :sample do
      use_doorkeeper_openid_connect
      use_doorkeeper do
        # Customize controllers
        controllers authorizations: 'doorkeeper_authorizations',
                    tokens: 'doorkeeper_tokens',
                    token_info: 'doorkeeper_token_info'

        skip_controllers :applications
      end

      resources :sessions, only: [:new, :create, :destroy]
    end
  end
end
