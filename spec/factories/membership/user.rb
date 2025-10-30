# typed: false

FactoryBot.define do
  factory :membership_user, class: 'Membership::User' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    membership { create(:membership, tenant_id: self.tenant_id) }
    membership_contract { create(:membership_contract, tenant_id: self.tenant_id) }
    activated_at { Time.current }
    expired_at { 1.year.from_now }
    status { 'active' }

    trait :with_group do
      membership_group
    end

    trait :expired do
      expired_at { 1.day.ago }
      status { 'expired' }
    end
  end
end
