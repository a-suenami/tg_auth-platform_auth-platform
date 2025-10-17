# typed: false

FactoryBot.define do
  factory :membership_plan_payment_method, class: 'Membership::PlanPaymentMethod' do
    tenant_id { current_tenant.id }
    membership_plan { create(:membership_plan, tenant_id: self.tenant_id) }
    payment_type { 'credit_card' }
    stripe_record_price { nil }
    is_active { true }
  end
end
