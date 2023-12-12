# typed: false

FactoryBot.define do
  factory :tenant_setting do
    tenant_id { create(:tenant).id }
    google_cloud_service_account { nil }
    google_cloud_project_id { nil }
    recaptcha_enterprise_checkbox_site_key { nil }
    recaptcha_enterprise_score_based_site_key { nil }
  end
end
