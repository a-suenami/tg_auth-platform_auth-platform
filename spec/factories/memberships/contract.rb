# typed: false

FactoryBot.define do
  factory :memberships__contract, class: 'Memberships::Contract' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    expires_at { nil }
    cancel_at_period_end { false }
    status { 'active' }

    trait :pending do
      status { 'pending' }
    end

    trait :expired do
      status { 'expired' }
      expires_at { 1.day.ago }
    end

    trait :canceled do
      status { 'canceled' }
    end

    trait :cancel_at_period_end do
      cancel_at_period_end { true }
    end
  end
end
