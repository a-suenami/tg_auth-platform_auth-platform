# typed: false

FactoryBot.define do
  factory :memberships__plan_payment_method, class: 'Memberships::PlanPaymentMethod' do
    tenant_id { current_tenant.id }
    membership_plan { create(:memberships__plan, tenant_id: self.tenant_id) }
    payment_type { 'credit_card' }
    stripe_record_price { nil }
    is_active { true }
  end
end
