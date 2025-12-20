# typed: false
# frozen_string_literal: true

require 'flipper'
require 'flipper/adapters/redis'
require 'flipper/ui'

Flipper.configure do |config|
  config.adapter do
    client = Redis.new(url: Settings.redis.url)
    Flipper::Adapters::Redis.new(client)
  end
end

# Configure UI
Flipper::UI.configure do |config|
  config.banner_text = 'Auth Platform Feature Flags'
  config.banner_class = 'info'
  config.feature_creation_enabled = true
  config.feature_removal_enabled = true
end
