# typed: false

FactoryBot.define do
  factory :membership_plan_component, class: 'Membership::PlanComponent' do
    tenant_id { current_tenant.id }
    membership { create(:membership, tenant_id: self.tenant_id) }
    membership_plan { create(:membership_plan, tenant_id: self.tenant_id) }
  end
end
