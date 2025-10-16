# typed: false

FactoryBot.define do
  factory :memberships__contract_term, class: 'Memberships::ContractTerm' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    membership_contract { create(:memberships__contract, tenant_id: self.tenant_id) }
    membership_plan { create(:memberships__plan, tenant_id: self.tenant_id) }
    status { 'current' }

    trait :upcoming do
      status { 'upcoming' }
    end

    trait :closed do
      status { 'closed' }
    end
  end
end
