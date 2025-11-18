Rails.application.routes.draw do
  namespace :webhook_area, path: :webhook do
    # Stripe webhook
    post 'stripe', to: 'stripe_webhooks#create'

    # Komoju webhook
    post 'komoju', to: 'komoju_webhooks#create'
  end
end
