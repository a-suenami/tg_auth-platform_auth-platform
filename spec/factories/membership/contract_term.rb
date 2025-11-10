# typed: false

FactoryBot.define do
  factory :membership_contract_term, class: 'Membership::ContractTerm' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    membership_contract { create(:membership_contract, tenant_id: self.tenant_id) }
    membership_plan { create(:membership_plan, tenant_id: self.tenant_id) }
    payment_type { 'credit_card' }
    status { 'current' }

    trait :upcoming do
      status { 'upcoming' }
    end

    trait :closed do
      status { 'closed' }
    end
  end
end
