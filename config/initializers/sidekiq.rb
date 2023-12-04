# ==============================================================================
# config - initializers - sidekiq
# ==============================================================================
# require 'sidekiq/api'

redis_setting = {
  url: Settings.redis.url,
}

Sidekiq.configure_server do |config|
  config.redis = redis_setting

  # Sidekiq Pro: reliable settings https://github.com/sidekiq/sidekiq/wiki/Reliability
  config.super_fetch!
  config.reliable_scheduler!

  # config.error_handlers << proc do |ex, ctx_hash|
  #   #  Sidekiq.logger.warn "Error! #{ex} #{ctx_hash}"
  #   config.logger.warn "Error! #{ex} #{ctx_hash}"
  # end
end

Sidekiq.configure_client do |config|
  config.redis = redis_setting
end

# Sidekiq Pro Reliability Client: https://github.com/sidekiq/sidekiq/wiki/Pro-Reliability-Client
# This should not go in a Sidekiq.configure_{client,server} block.
Sidekiq::Client.reliable_push! unless Rails.env.test?
