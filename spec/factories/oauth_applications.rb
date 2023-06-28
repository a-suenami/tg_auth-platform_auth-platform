# typed: false

FactoryBot.define do
  factory :oauth_application do
    tenant_id { create(:tenant).id }
    scopes { 'public' }
  end
end
