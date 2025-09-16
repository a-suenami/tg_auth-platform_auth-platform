# typed: false

FactoryBot.define do
  factory :memberships__trial_history, class: 'Memberships::TrialHistory' do
    tenant_id { create(:tenant).id }
    membership { create(:membership) }
    fingerprint { 'test_fingerprint' }
    started_at { Time.current }
    ended_at { 30.days.from_now }
    status { 'active' }
  end
end
