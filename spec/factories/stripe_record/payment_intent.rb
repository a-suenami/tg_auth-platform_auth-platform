# typed: false

FactoryBot.define do
  factory :stripe_record_payment_intent, class: 'StripeRecord::PaymentIntent' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    api_key_account { nil }
    invoice { nil }
    chargeable { nil }
    latest_charge { nil }

    sequence(:remote_id) { |n| "pi_#{n}" }
    currency { 'jpy' }
    amount { 1000 }
    status { 'requires_confirmation' }
    customer_id { 'cus_test123' }
    client_secret { 'pi_test123_secret' }
    confirmation_method { 'automatic' }
    capture_method { 'automatic' }
    payment_method_id { 'pm_test123' }
    payment_method_configuration_details { {} }
    payment_method_options { { card: { request_three_d_secure: 'automatic' } } }
    cancellation_reason { nil }
    description { 'Test payment' }
    metadata { {} }
    next_action { nil }
    on_behalf_of_id { nil }
    application_fee_amount { nil }
    transfer_data { nil }
    transfer_group { nil }
    created { Time.current.to_i }
    canceled_at { nil }
    connect_account { nil }
    charge_type { nil }

    trait :succeeded do
      status { 'succeeded' }
    end

    trait :requires_action do
      status { 'requires_action' }
      next_action { { type: 'redirect_to_url', redirect_to_url: { url: 'https://example.com/3ds' } } }
    end

    trait :requires_confirmation do
      status { 'requires_confirmation' }
    end

    trait :processing do
      status { 'processing' }
    end

    trait :requires_capture do
      status { 'requires_capture' }
    end

    trait :canceled do
      status { 'canceled' }
      canceled_at { Time.current }
      cancellation_reason { 'abandoned' }
    end

    trait :with_invoice do
      invoice { create(:stripe_record_invoice, tenant_id: self.tenant_id) }
    end

    trait :with_latest_charge do
      latest_charge { create(:stripe_record_charge, tenant_id: self.tenant_id) }
    end

    trait :with_api_key_account do
      api_key_account { create(:stripe_record_account, tenant_id: self.tenant_id) }
    end

    trait :connect do
      connect_account { create(:stripe_record_account, tenant_id: self.tenant_id) }
      charge_type { 'direct_charges' }
      application_fee_amount { 100 }
    end
  end
end
