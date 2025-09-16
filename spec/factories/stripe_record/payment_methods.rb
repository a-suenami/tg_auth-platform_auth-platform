# typed: false

FactoryBot.define do
  factory :stripe_record_payment_method, class: 'StripeRecord::PaymentMethod' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    type { 'card' }
    billing_details { {} }
    card { {} }
    customer_id { '1234567890123' }
    detached_at { nil }
    created_at { Time.current }
    updated_at { Time.current }
    api_key_account { create(:stripe_record_account, :skip_validate, tenant_id: tenant_id) }
    connect_account { nil }
    charge_type { nil }
  end
end
