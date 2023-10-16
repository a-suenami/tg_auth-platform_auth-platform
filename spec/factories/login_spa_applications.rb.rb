# typed: false

FactoryBot.define do
  factory :login_spa_application do
    tenant_id { create(:tenant).id }
    name { 'Login SPA' }
    uid { SecureRandom.uuid }
    login_url { 'https://example.com' }
    redirect_url_on_password_reset { 'https://example.com/password_reset/edit' }
  end
end
