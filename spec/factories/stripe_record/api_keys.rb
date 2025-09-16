# typed: false

FactoryBot.define do
  factory :stripe_record_api_key, class: 'StripeRecord::APIKey' do
    tenant_id { create(:tenant).id }

    sequence(:remote_id) { |n| "ak_#{n}" }
    sequence(:display_name) { |n| "API Key #{n}" }
    publishable_key { 'pk_test_1234567890' }
    secret_key_encrypted { 'sk_test_1234567890' }
    secret_key { 'sk_test_1234567890' }

    trait :live do
      publishable_key { 'pk_live_1234567890' }
      secret_key_encrypted { 'sk_live_1234567890' }
      secret_key { 'sk_live_1234567890' }
    end

    trait :test do
      publishable_key { 'pk_test_1234567890' }
      secret_key_encrypted { 'sk_test_1234567890' }
      secret_key { 'sk_test_1234567890' }
    end

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
