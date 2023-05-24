# typed: false

FactoryBot.define do
  factory :email_template do
    tenant_id { create(:tenant).id }
    name { 'メールテンプレート名' }
    template_type { 'email_address_verification' }
    subject { 'メールテンプレート 件名' }
    body { '<p>メール本文</p>' }
  end
end
