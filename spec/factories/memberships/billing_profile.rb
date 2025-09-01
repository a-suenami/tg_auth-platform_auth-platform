# typed: false

FactoryBot.define do
  factory :memberships__billing_profile, class: 'Memberships::BillingProfile' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    membership_plan { create(:membership_plan) }
    membership_contract { create(:membership_contract) }
    payment_type { 'credit_card' }
    payment_provider { 'stripe' }
    external_id { nil }
    phase { 'current' }
    activated_at { Time.current }
    expires_at { 1.year.from_now }
    status { 'active' }
    recurrence { false }
    revision { 1 }
    chargeable { nil }

    trait :credit_card do
      payment_type { 'credit_card' }
      payment_provider { 'stripe' }
    end

    trait :convenience do
      payment_type { 'convenience' }
      payment_provider { 'komoju' }
    end

    trait :campaign_code do
      payment_type { 'campaign_code' }
      payment_provider { 'other' }
    end

    trait :external_linkage do
      payment_type { 'external_linkage' }
      payment_provider { 'other' }
    end

    trait :pending do
      phase { 'pending' }
      status { 'pending' }
    end

    trait :upcoming do
      phase { 'upcoming' }
      status { 'pending' }
    end

    trait :closed do
      phase { 'closed' }
      status { 'expired' }
    end

    trait :recurring do
      recurrence { true }
    end
  end
end
