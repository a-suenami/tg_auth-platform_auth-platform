# typed: true

ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?

require 'rspec/rails'
# require 'knapsack_pro'

Dir[Rails.root.join('spec', 'helpers', '**', '*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.example_status_persistence_file_path = 'spec/examples.txt'

  config.define_derived_metadata do |meta|
    meta[:aggregate_failures] = true unless meta.key?(:aggregate_failures)
  end

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.shared_context_metadata_behavior = :apply_to_host_groups
  config.profile_examples = 10
  config.fixture_path = "#{Rails.root}/spec/fixtures"
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.before(:suite) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean_with(:truncation)

    unless ENV['PARALLEL_SPLIT_TEST']
      # CI などで並列実行する際は事前に `bundle exec thor dynamodb:migrate` を実行する
      # Execute `bundle exec thor dynamodb:migrate` before parallel execution for CI etc.

      # DynamoDBHelpers.delete_dynamodb_table
      # DynamoDBHelpers.migrate_dynamodb
    end

    # DynamoDBHelpers.seed_dynamodb(:slashgift)

    Redis.define_singleton_method(:some) do
      # 並列にテストを走らせたときにそれぞれ異なる db を利用する（+ 3 は適当）
      # Use a different db for each when running tests in parallel (+ 3 is approx num)

      @some ||= Redis.new(url: Settings.redis.url, db: ENV['TEST_ENV_NUMBER'].to_i + 3)
    end
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.before do
    Redis.some.flushdb
    RequestStore.clear!
  end

  # Temporary disable bullet
  # if Bullet.enable?
  #   config.before do
  #     Bullet.start_request
  #   end

  #   config.after do
  #     Bullet.perform_out_of_channel_notifications if Bullet.notification?
  #     Bullet.end_request
  #   end
  # end

  # cache store を option で切り替える
  config.around do |example|
    if example.metadata[:cache_store].present?
      default_cache_store = Rails.cache
      option = example.metadata[:cache_store_option] || {}
      # 並列にテストを走らせたときにそれぞれ異なる db を利用する（+ 3 は適当）
      option[:db] = ENV['TEST_ENV_NUMBER'].to_i + 3 if example.metadata[:cache_store] == :redis_cache_store

      cache_store = ActiveSupport::Cache.lookup_store(example.metadata[:cache_store], option)
      Rails.cache = cache_store

      example.run

      Rails.cache.clear rescue nil
      Rails.cache = default_cache_store
    else
      example.run
    end
  end

  # locale を option で切り替える
  config.around do |example|
    if example.metadata[:locale]
      I18n.with_locale(example.metadata[:locale]) do
        example.run
      end
    else
      example.run
    end
  end


  config.include RSpec::RequestDescriber, type: :request
  config.include RequestHelpers, type: :request
  config.include FactoryBot::Syntax::Methods
  config.include T::Private::Methods
  # config.include ActiveSupport::Testing::TimeHelpers
  # config.include DynamoDBHelpers
end

RSpec::Matchers.define_negated_matcher :not_change, :change

# KnapsackPro::Adapters::RSpecAdapter.bind

Settings.reload!
