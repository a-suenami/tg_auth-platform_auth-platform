# typed: false

FactoryBot.define do
  factory :stripe_record_account, class: 'StripeRecord::Account' do
    tenant_id { create(:tenant).id }
    api_key { create(:stripe_record_api_key, :skip_validate) }
    controlling_platform { nil }

    sequence(:remote_id) { |n| "acct_#{n}" }
    type { 'standard' }
    business_profile_name { 'Test Business' }
    payments_statement_descriptor { 'TEST' }
    payments_statement_descriptor_kana { nil }
    payments_statement_descriptor_kanji { nil }
    sequence(:display_name) { |n| "Test Account #{n}" }

    trait :custom do
      type { 'custom' }
    end

    trait :express do
      type { 'express' }
    end

    trait :standard do
      type { 'standard' }
    end

    trait :connect_account do
      controlling_platform { create(:stripe_record_account, :skip_validate) }
      api_key { nil }
    end

    trait :with_tenant_stripe_account do
      after(:create) do |account|
        create(:tenant_stripe_account, stripe_account: account)
      end
    end

    trait :skip_validate do
      to_create { |instance| instance.save(validate: false) }
    end
  end
end
