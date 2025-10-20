# typed: false

FactoryBot.define do
  factory :membership_plan_payment_method_mapping, class: 'Membership::PlanPaymentMethodMapping' do
    tenant_id { create(:tenant).id }
    membership_plan { create(:membership_plan, tenant_id: self.tenant_id) }
    membership_plan_payment_method { create(:membership_plan_payment_method, tenant_id: self.tenant_id, membership_plan: self.membership_plan) }
    priceable { create(:stripe_record_price, tenant_id: self.tenant_id) }
    amount { 1000 }
    currency { 'JPY' }
    is_active { true }
  end
end
