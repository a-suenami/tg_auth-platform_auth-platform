# typed: false

FactoryBot.define do
  factory :stripe_record_payment_method, class: 'StripeRecord::PaymentMethod' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    type { 'card' }
    billing_details { {} }
    card { {} }
    customer_id { '1234567890123' }
    detached_at { nil }
    created_at { Time.current }
    updated_at { Time.current }
    api_key_account { nil }
    connect_account { nil }
    charge_type { nil }
  end
end
