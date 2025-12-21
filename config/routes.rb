# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'health_check', to: 'application#health_check'

  # Lookbook UI component preview (development only)
  mount Lookbook::Engine, at: '/lookbook' if Rails.env.development?

  use_doorkeeper_openid_connect
  use_doorkeeper do
    skip_controllers :applications
  end
end
