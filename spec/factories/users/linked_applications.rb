# typed: false

FactoryBot.define do
  factory :users__linked_application, class: 'Users::LinkedApplication' do
    tenant_id { create(:tenant).id }
    user { create(:user) }
    oauth_application { create(:oauth_application) }
    scopes { 'public openid' }
    last_linked_at { Time.zone.now }
  end
end
