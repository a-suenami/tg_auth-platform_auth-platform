# typed: false
# frozen_string_literal: true

require 'flipper'
require 'flipper/adapters/active_record'
require 'flipper/adapters/active_support_cache_store'
require 'flipper/ui'

Flipper.configure do |config|
  config.adapter do
    # Primary storage: ActiveRecord (PostgreSQL)
    ar_adapter = Flipper::Adapters::ActiveRecord.new

    # Cache layer: Redis via ActiveSupport cache store
    redis_cache = ActiveSupport::Cache::RedisCacheStore.new(
      url: Settings.redis.url,
      namespace: 'flipper'
    )

    # Third argument is expires_in (5 minutes)
    Flipper::Adapters::ActiveSupportCacheStore.new(ar_adapter, redis_cache, 5.minutes)
  end
end

# Configure UI
Flipper::UI.configure do |config|
  config.banner_text = 'Auth Platform Feature Flags'
  config.banner_class = 'info'
  config.feature_creation_enabled = true
  config.feature_removal_enabled = true
end
