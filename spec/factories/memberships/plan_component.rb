# typed: false

FactoryBot.define do
  factory :memberships__plan_component, class: 'Memberships::PlanComponent' do
    tenant_id { current_tenant.id }
    membership { create(:membership) }
    membership_plan { create(:memberships__plan) }
  end
end
