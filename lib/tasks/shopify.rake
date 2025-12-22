# typed: false
# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
# require 'shopify_api'

namespace :shopify do
  def initialize_shopify_session
    shop_name = ENV.fetch('STORE_NAME', nil)
    api_token = ENV.fetch('SHOPIFY_API_TOKEN', nil)

    ShopifyAPI::Context.setup(
      api_key: ENV.fetch('SHOPIFY_API_KEY', nil),
      api_secret_key: ENV.fetch('SHOPIFY_API_SECRET_KEY', nil),
      scope: 'write_webhooks', # Updated scope
      is_embedded: false, # Set to false if not embedded
      api_version: ENV.fetch('SHOPIFY_API_VERSION', '2025-07'),
      is_private: true,
    )

    session = ShopifyAPI::Auth::Session.new(
      shop: "#{shop_name}.myshopify.com",
      access_token: api_token,
    )
    ShopifyAPI::Context.activate_session(session)

    client = ShopifyAPI::Clients::Graphql::Admin.new(session:)

    [session, client]
  end

  task register_webhook_customers_create: :environment do
    arn = ENV.fetch('EVENT_BRIDGE_ARN', nil)
    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      mutation ($arn: ARN) {
        eventBridgeWebhookSubscriptionCreate(
          topic: CUSTOMERS_CREATE
          webhookSubscription: {
            arn: $arn
            format: JSON
          }
        ) {
          webhookSubscription {
            id
          }
          userErrors {
            message
          }
        }
      }
    GRAPHQL

    result = client.query(query:, variables: { arn: })

    # Add this debug output
    puts 'Full Shopify response:'
    puts JSON.pretty_generate(result.body)

    # Updated error handling
    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    user_errors = result.body['data']['eventBridgeWebhookSubscriptionCreate']['userErrors']
    raise StandardError, user_errors.to_s if user_errors.any?

    p result.body['data']['eventBridgeWebhookSubscriptionCreate']['webhookSubscription']
  end

  task register_webhook_customers_update: :environment do
    arn = ENV.fetch('EVENT_BRIDGE_ARN', nil)
    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      mutation ($arn: ARN) {
        eventBridgeWebhookSubscriptionCreate(
          topic: CUSTOMERS_UPDATE
          webhookSubscription: {
            arn: $arn
            format: JSON
          }
        ) {
          webhookSubscription {
            id
          }
          userErrors {
            message
          }
        }
      }
    GRAPHQL

    result = client.query(query:, variables: { arn: })

    # Add this debug output
    puts 'Full Shopify response:'
    puts JSON.pretty_generate(result.body)

    # Updated error handling
    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    user_errors = result.body['data']['eventBridgeWebhookSubscriptionCreate']['userErrors']
    raise StandardError, user_errors.to_s if user_errors.any?

    p result.body['data']['eventBridgeWebhookSubscriptionCreate']['webhookSubscription']
  end

  task register_webhook_customer_tags_added: :environment do
    arn = ENV.fetch('EVENT_BRIDGE_ARN', nil)
    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      mutation ($arn: ARN) {
        eventBridgeWebhookSubscriptionCreate(
          topic: CUSTOMER_TAGS_ADDED
          webhookSubscription: {
            arn: $arn
            format: JSON
          }
        ) {
          webhookSubscription {
            id
          }
          userErrors {
            message
          }
        }
      }
    GRAPHQL

    result = client.query(query:, variables: { arn: })

    puts 'Full Shopify response:'
    puts JSON.pretty_generate(result.body)

    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    user_errors = result.body['data']['eventBridgeWebhookSubscriptionCreate']['userErrors']
    raise StandardError, user_errors.to_s if user_errors.any?

    p result.body['data']['eventBridgeWebhookSubscriptionCreate']['webhookSubscription']
  end

  task register_webhook_customer_tags_removed: :environment do
    arn = ENV.fetch('EVENT_BRIDGE_ARN', nil)
    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      mutation ($arn: ARN) {
        eventBridgeWebhookSubscriptionCreate(
          topic: CUSTOMER_TAGS_REMOVED
          webhookSubscription: {
            arn: $arn
            format: JSON
          }
        ) {
          webhookSubscription {
            id
          }
          userErrors {
            message
          }
        }
      }
    GRAPHQL

    result = client.query(query:, variables: { arn: })

    puts 'Full Shopify response:'
    puts JSON.pretty_generate(result.body)

    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    user_errors = result.body['data']['eventBridgeWebhookSubscriptionCreate']['userErrors']
    raise StandardError, user_errors.to_s if user_errors.any?

    p result.body['data']['eventBridgeWebhookSubscriptionCreate']['webhookSubscription']
  end

  task show_webhook: :environment do
    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      {
        webhookSubscriptions(first: 10) {
          edges {
            node {
              id,
              topic,
              endpoint {
                __typename
                ... on WebhookHttpEndpoint {
                  callbackUrl
                }
                ... on WebhookEventBridgeEndpoint {
                  arn
                }
                ... on WebhookPubSubEndpoint {
                  pubSubProject
                  pubSubTopic
                }
              }
            }
          }
        }
      }
    GRAPHQL

    result = client.query(query:)

    # Updated error handling
    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    p(result.body['data']['webhookSubscriptions']['edges'].pluck('node'))
  end

  task :delete_webhook, [:webhook_id] => :environment do |_task, args|
    webhook_id = args[:webhook_id] || ENV.fetch('WEBHOOK_ID', nil)

    if webhook_id.blank?
      puts 'Usage: rake shopify:delete_webhook[gid://shopify/WebhookSubscription/525699895]'
      puts 'Or: WEBHOOK_ID=gid://shopify/WebhookSubscription/525699895 rake shopify:delete_webhook'
      puts 'Please provide a webhook subscription ID'
      exit 1
    end

    _, client = initialize_shopify_session

    query = <<~GRAPHQL
      mutation webhookSubscriptionDelete($id: ID!) {
        webhookSubscriptionDelete(id: $id) {
          userErrors {
            field
            message
          }
          deletedWebhookSubscriptionId
        }
      }
    GRAPHQL

    variables = { id: webhook_id }

    result = client.query(query:, variables:)

    puts 'Full Shopify response:'
    puts JSON.pretty_generate(result.body)

    unless result.code == 200
      raise StandardError, "API request failed with status #{result.code}: #{result.body}"
    end

    user_errors = result.body['data']['webhookSubscriptionDelete']['userErrors']
    if user_errors.any?
      puts 'Error occurred:'
      user_errors.each do |error|
        puts "- #{error['field']}: #{error['message']}"
      end
      exit 1
    end

    deleted_id = result.body['data']['webhookSubscriptionDelete']['deletedWebhookSubscriptionId']
    puts "Successfully deleted webhook subscription: #{deleted_id}"
  end
end
# rubocop:enable Metrics/BlockLength
