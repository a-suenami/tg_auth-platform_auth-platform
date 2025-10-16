# typed: false

FactoryBot.define do
  factory :memberships__plan_component, class: 'Memberships::PlanComponent' do
    tenant_id { current_tenant.id }
    membership { create(:membership, tenant_id: self.tenant_id) }
    membership_plan { create(:memberships__plan, tenant_id: self.tenant_id) }
  end
end
