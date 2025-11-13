# typed: false

FactoryBot.define do
  factory :payment_transaction, class: 'Payment::Transaction' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    membership_contract { create(:membership_contract, tenant_id: self.tenant_id) }
    payment_type { 'credit_card' }
    payment_provider { 'stripe' }
    # no direct external id field; identify via chargeable

    activated_at { Time.current }
    expired_at { 1.year.from_now }
    status { 'active' }
    recurrence { false }
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


    trait :recurring do
      recurrence { true }
    end
  end
end
