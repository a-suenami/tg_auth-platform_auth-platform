# typed: false

FactoryBot.define do
  factory :memberships__trial_history, class: 'Memberships::TrialHistory' do
    tenant_id { create(:tenant).id }
    membership { create(:membership) }
    fingerprint { 'test_fingerprint' }
    trial_start { Time.current }
    trial_end { 30.days.from_now }
    trial_period_days { 30 }
  end
end
