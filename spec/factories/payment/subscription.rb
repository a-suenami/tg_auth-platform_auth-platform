# typed: false

FactoryBot.define do
  factory :payment_subscription, class: 'Payment::Subscription' do
    tenant_id { create(:tenant).id }
    user { create(:user, tenant_id: self.tenant_id) }
    membership_contract { create(:membership_contract, tenant_id: self.tenant_id) }
    subscribable { create(:stripe_record_subscription, tenant_id: self.tenant_id) }

    trait :with_stripe_subscription do
      subscribable { create(:stripe_record_subscription, tenant_id: self.tenant_id) }
    end

    trait :with_setup_intent do
      subscribable { create(:stripe_record_setup_intent, tenant_id: self.tenant_id) }
    end
  end
end
