# typed: false

FactoryBot.define do
  factory :oauth_access_token do
    tenant_id { create(:tenant).id }
  end
end
