# frozen_string_literal: true

# Feature flags managed by Flipper (stored in Redis)
# Add new features to FeatureFlagRegistry and run `rails db:seed_fu FILTER=023_feature_flags`

FeatureFlagRegistry.seed!
