# typed: false

FactoryBot.define do
  factory :stripe_record_trial_history, class: 'StripeRecord::TrialHistory' do
    tenant_id { create(:tenant).id }
    membership { create(:membership) }
    fingerprint { 'test_fingerprint' }
    trial_start { Time.current }
    trial_end { 30.days.from_now }
    trial_period_days { 30 }
  end
end
