# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  use_doorkeeper_openid_connect
  use_doorkeeper
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'health_check', to: 'application#health_check'
end
