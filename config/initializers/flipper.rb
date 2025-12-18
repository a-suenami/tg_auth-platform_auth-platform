# typed: true
# frozen_string_literal: true

require 'flipper'
require 'flipper/adapters/redis'

Flipper.configure do |config|
  config.adapter do
    redis = Redis.new(url: Settings.redis.url, db: 0)
    Flipper::Adapters::Redis.new(redis)
  end
end
