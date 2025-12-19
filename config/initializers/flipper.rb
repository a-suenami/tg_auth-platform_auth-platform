# typed: false
# frozen_string_literal: true

require 'flipper'
require 'flipper/adapters/active_record'
require 'flipper/ui'

Flipper.configure do |config|
  config.adapter { Flipper::Adapters::ActiveRecord.new }
end

# Configure UI
Flipper::UI.configure do |config|
  config.banner_text = 'Auth Platform Feature Flags'
  config.banner_class = 'info'
  config.feature_creation_enabled = true
  config.feature_removal_enabled = true
end
