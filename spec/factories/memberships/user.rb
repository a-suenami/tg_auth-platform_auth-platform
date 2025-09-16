# typed: false

FactoryBot.define do
  factory :memberships__user, class: 'Memberships::User' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    membership { create(:membership) }
    membership_contract { create(:memberships__contract) }
    expires_at { 1.year.from_now }
    status { 'active' }

    trait :with_group do
      membership_group
    end

    trait :expired do
      expires_at { 1.day.ago }
      status { 'expired' }
    end
  end
end
