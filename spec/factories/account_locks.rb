# typed: false

FactoryBot.define do
  factory :account_lock do
    tenant_id { create(:tenant).id }
    email { '' }
    failed_attempts { 0 }
    unlock_token { '' }
    lock_expired_at { Time.zone.now }
    last_failed_at { Time.zone.now }
  end
end
