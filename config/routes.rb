# typed: false
# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  get 'health_check', to: 'application#health_check'

  # ルートパスのリダイレクト
  root to: 'root_redirect#index'

  use_doorkeeper_openid_connect
  use_doorkeeper do
    skip_controllers :applications
  end
end
