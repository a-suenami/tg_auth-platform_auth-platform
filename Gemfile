# frozen_string_literal: true

# ==============================================================================
# Gemfile
# ==============================================================================
source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.2.2'

# ------------------------------------------------------------------------------
# Core, DB
# ------------------------------------------------------------------------------
# Rails
gem 'rails', '~> 7.0.4.2'
# Use Puma as the app server
gem 'puma', '~> 6.1.0'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.4.0'
# # Use Redis for in-memory database
gem 'redis', '~> 5.0', '>= 5.0.6'
gem 'redis-namespace', '~> 1.10.0'
# # Mutex by Redis
# gem 'redlock', '~> 2.0.1'
# # Support for Cross-Origin Resource Sharing (CORS) for Rack compatible web applications
gem 'rack-cors', '~> 2.0.0'
# # Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.16.0', require: false
# Use ridgepole for schema management
gem 'ridgepole', '~> 1.2.0'
# # Simple, efficient background processing for Ruby
# gem 'sidekiq', '~> 6.5.0'
# # adds support for queueing jobs in a recurring way to sidekiq
# gem 'sidekiq-scheduler', '~> 4.0.0'
# # An extension to the sidekiq message processing to track your jobs
# gem 'sidekiq-status', '~> 2.1.0'
# # Ensure uniqueness of your Sidekiq jobs
# gem 'sidekiq-unique-jobs', '~> 7.1.0'
# Enable per-request global storage
gem 'request_store', '~> 1.5.1'
gem 'request_store-sidekiq', '~> 0.1.0'
# # AuthorizationP
# gem 'pundit', '~> 2.3.0'
# # Secure hash algorithm
gem 'bcrypt', '~> 3.1.0'
# # Preload using if condition
# gem 'activerecord-belongs_to_if', '~> 0.1.0'
# # A rich library for bulk inserting data using ActiveRecord
# gem 'activerecord-import', '~> 1.4.0'
# # Action Authority
# gem 'banken', '~> 1.0.0'
# # Removes invalid UTF8 characters from the URL and other env vars
# gem 'utf8-cleaner', '~> 1.0'
# OAuth 2 provider
gem 'doorkeeper', '~> 5.6.6'
gem 'doorkeeper-openid_connect', '~> 1.8.4'
gem 'omniauth-auth0', '~> 3.0'
gem 'omniauth-rails_csrf_protection', '~> 1.0'
gem 'auth0', '~> 5.12'
gem 'rack-attack', '~> 6.6.1'
# ------------------------------------------------------------------------------
# Front
# ------------------------------------------------------------------------------
# Use slim as template language
gem 'slim-rails', '~> 3.6.1'
# # JSON API serializer
gem 'jb', '~> 0.8.0'
# gem 'jsonapi-serializer', git: 'https://github.com/twogate/fast_jsonapi', ref: '62c1cc8'
# Pagination
gem 'api-pagination', '~> 5.0.0'
gem 'pagy', '~> 6.0.1'
# # link_to helper
# gem 'active_link_to', '~> 1.0.0'
# # Nested form helper
# gem 'cocoon', '~> 1.2', '>= 1.2.15'
# Use Vite as frontend tool
gem 'vite_rails', '~> 4.0.0.alpha1'
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem 'turbo-rails', '~> 1.1.0'
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem 'stimulus-rails', '~> 1.0.0'
# Template Engine
gem 'liquid', '~> 5.4.0'

# ------------------------------------------------------------------------------
# Utilities
# ------------------------------------------------------------------------------
# Use Pry as rails console
gem 'pry', '~> 0.14.2'
gem 'pry-rails', '~> 0.3.9'
# Manage multi-environment settings
gem 'config', '~> 4.1.0'
# # Provides a client interface for the Sentry error logger
gem 'sentry-rails', '~> 5.8.0'
gem 'sentry-ruby', '~> 5.8.0'
gem 'sentry-sidekiq', '~> 5.8.0'
# Make managing seeds better
gem 'seed-fu', '~> 2.3.0'
# # Easily generater of fake data
# gem 'ffaker', '~> 2.21.0'
# # Json Web Token
# gem 'jwt', '~> 2.7.0'
# Use rails-i18n as a set of common locale data
gem 'rails-i18n', '~> 7.0.0'
# # Framework for factories
gem 'factory_bot_rails', '~> 6.2.0'
# # Enumerated attributes with I18n
gem 'enumerize', '~> 2.5.0'
# # AWS client gems
# gem 'aws-record', '~> 2.10.1'
# gem 'aws-sdk-dynamodb', '~> 1.81.0'
gem 'aws-sdk-rails', '~> 3.7.1'
# gem 'aws-sdk-s3', '~> 1.119.1'
# gem 'aws-sdk-sqs', '~> 1.53.0'
# Encrypt yaml
gem 'yaml_vault', '~> 1.3.2'
# # For counter caches
# gem 'counter_culture', '~> 3.3.0'
# # FCM push notification utility
# gem 'fcmpush', '~> 1.4.0'
# # HTTP client
gem 'faraday', '~> 2.7.4'
# gem 'faraday-http-cache', '~> 2.4.0'
# # Convert bytesize to human readable string
# gem 'bytesize', '~> 0.1.0'
# # SameSite option
# gem 'rails_same_site_cookie', git: 'https://github.com/twogate/rails_same_site_cookie.git', ref: '5a31856'
# # Logger extension
gem 'lograge', '~> 0.12.0'
# # User-Agent parser
# gem 'rack-user_agent', '~> 0.5.0'
# # japanese prefecture
gem 'jp_prefecture', '~> 1.1.0'
# # SendGrid client
# gem 'sendgrid-ruby', '~> 6.6.0'
# # check reserved subdomain
# gem 'reserved_subdomain', '~> 0.0.4'
# # Custom ordering
# gem 'order_as_specified', '~> 1.7.0'
# # Datadog tracing client
# gem 'ddtrace', '~> 1.9.0'
# # Retry block utility
# gem 'retryable', '~> 3.0.5'
# # As Firebase Authentication SDK
# gem 'google-apis-identitytoolkit_v3', '~> 0.13.0'
# country code collection
gem 'countries', '~> 5.5.0'
# Phone number validator
gem 'phonelib', '~> 0.8.2'

# typing
gem 'sorbet-runtime'

# ------------------------------------------------------------------------------
# Development and Test Only
# ------------------------------------------------------------------------------
group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  # gem 'pry-byebug', '~> 3.9.0'
  # gem 'pry-stack_explorer', '~> 0.4.0'
  # Ruby code style checking
  gem 'rubocop', '~> 1.46.0'
  # A RuboCop extension focused on enforcing Rails best practices and coding conventions
  gem 'rubocop-rails', '~> 2.18'
  # RuboCop extension for RSpec
  gem 'rubocop-rspec', '~> 2.18.1'
  # Testing framework
  gem 'rspec-rails', '~> 6.0.1'
  # Speed up RSpec using Spring
  gem 'spring-commands-rspec', '~> 1.0.4'
  # # Simplify test code
  # gem 'shoulda-matchers', '~> 5.3.0'
  # # Simplify request test code
  gem 'rspec-request_describer', '~> 0.3.0'
  # # RSpect matchers
  # gem 'rspec-json_expectations', '~> 2.2.0'
  # # Run RSpec parallel
  # gem 'parallel_split_test', '~> 0.10.0'
  # gem 'parallel_tests', '~> 4.2.0'
  # # Strategies for cleaning databases
  gem 'database_cleaner', '~> 2.0.1'
  # Code coverage
  gem 'simplecov', '~> 0.22.0', require: false
  # Detect N + 1 queries
  gem 'bullet', '~> 7.0.7'
  # # Filesystem event
  # gem 'listen', '~> 3.8.0'
  # Patch-level verification for bundler
  gem 'bundler-audit', '~> 0.9.1'
  # # Preprocess Metabase flavored query
  # gem 'metasql', '~> 0.1.0'
  # # Parse PostgreSQL query statically
  # gem 'pg_query', '~> 4.2.0'
  # # Amazing print
  # gem 'amazing_print', '~> 1.4.0'
  # # Optimization of test case partitioning
  # gem 'knapsack_pro', '~> 3.7.0'

  # typing
  gem 'sorbet'
  gem 'rubocop-sorbet', require: false
  gem 'tapioca', require: false
  gem 'spoom', require: false
end

# ------------------------------------------------------------------------------
# Development Only
# ------------------------------------------------------------------------------
group :development do
  # Access an interactive console on exception pages or by calling 'console' anywhere in the code.
  gem 'web-console', '~> 4.2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring', '~> 4.1.1'
  gem 'spring-watcher-listen', '~> 2.1.0'
  # Run db:reset without stopping app
  gem 'pgreset', '~> 0.3.0'
  # IDE tools for code completion, inline documentation, and static analysis
  gem 'solargraph', '~> 0.48.0'
  # Generate Entity-Relationship Diagrams
  gem 'rails-erd', '~> 1.7.2'
  # Ruby Language Server by Shopify
  gem 'ruby-lsp', '~> 0.4.1'
end
