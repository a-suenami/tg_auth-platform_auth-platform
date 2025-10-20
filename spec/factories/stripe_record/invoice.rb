# typed: false

FactoryBot.define do
  factory :stripe_record_invoice, class: 'StripeRecord::Invoice' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }

    sequence(:remote_id) { |n| "in_#{n}" }
    status { 'draft' }
    confirmation_secret { nil }
    confirmation_secret_type { nil }
    payment_source { nil }

    trait :draft do
      status { 'draft' }
    end

    trait :open do
      status { 'open' }
    end

    trait :paid do
      status { 'paid' }
    end

    trait :uncollectible do
      status { 'uncollectible' }
    end

    trait :void do
      status { 'void' }
    end

    trait :with_confirmation_secret do
      confirmation_secret { 'pi_test123_secret' }
      confirmation_secret_type { 'payment_intent' }
    end

    trait :with_subscription do
      payment_source { create(:stripe_record_subscription, tenant_id: self.tenant_id) }
    end

    trait :with_payment_intent do
      payment_source { create(:stripe_record_payment_intent, tenant_id: self.tenant_id) }
    end
  end
end
