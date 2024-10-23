Rails.application.routes.draw do
  namespace :shopify_area, path: :shopify do
    get '/multipass/auth', to: 'multipass#auth'
    get '/multipass/auth/register', to: 'multipass#register'
    get '/multipass/auth/callback', to: 'multipass#callback'

    # webhooks
    put 'webhooks/eventbridge/shopify', to: 'webhooks/eventbridge/shopify#update'
  end
end
