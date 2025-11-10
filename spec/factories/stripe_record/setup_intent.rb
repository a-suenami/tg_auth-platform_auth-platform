# typed: false

FactoryBot.define do
  factory :stripe_record_setup_intent, class: 'StripeRecord::SetupIntent' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    api_key_account { nil }

    sequence(:remote_id) { |n| "seti_#{n}" }
    client_secret { 'seti_test123_secret' }
    customer_id { 'cus_test123' }
    on_behalf_of_id { nil }
    payment_method_id { 'pm_test123' }
    status { 'requires_confirmation' }
    usage { 'off_session' }
    activated_at { nil }
    connect_account { nil }
    charge_type { nil }

    trait :succeeded do
      status { 'succeeded' }
      activated_at { Time.current }
    end

    trait :requires_action do
      status { 'requires_action' }
    end

    trait :requires_confirmation do
      status { 'requires_confirmation' }
    end

    trait :requires_payment_method do
      status { 'requires_payment_method' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :canceled do
      status { 'canceled' }
    end

    trait :off_session do
      usage { 'off_session' }
    end

    trait :on_session do
      usage { 'on_session' }
    end

    trait :with_api_key_account do
      api_key_account { create(:stripe_record_account, tenant_id: self.tenant_id) }
    end

    trait :with_payment_method do
      payment_method { create(:stripe_record_payment_method, tenant_id: self.tenant_id) }
    end

    trait :with_subscription do
      subscription { create(:stripe_record_subscription, tenant_id: self.tenant_id) }
    end

    trait :connect do
      connect_account { create(:stripe_record_account, tenant_id: self.tenant_id) }
      charge_type { 'direct_charges' }
    end
  end
end
