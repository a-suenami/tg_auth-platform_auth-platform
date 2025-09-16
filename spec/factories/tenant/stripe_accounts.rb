# typed: false

FactoryBot.define do
  factory :tenant_stripe_account, class: 'Tenant::StripeAccount' do
    tenant_id { create(:tenant).id }
    stripe_account { nil }

    charge_type { nil }
    fee_rate { nil }
    tax_rate_id { nil }
    webhook_secret { nil }

    trait :with_account do
      stripe_account {
        create(:stripe_record_account, :skip_validate,
          tenant_id: tenant_id,
          remote_id: 'acct_test123',
          type: 'standard',
          display_name: 'auth-platform-local-test',
          business_profile_name: nil,
          payments_statement_descriptor: 'LOCALTESTHOGEHOGE',
          payments_statement_descriptor_kana: 'ローカルテストホゲホゲ',
          payments_statement_descriptor_kanji: '明細書表記ローカルテストホゲホゲ',)
      }
    end

    trait :with_tax_rate do
      tax_rate_id { 'txr_test_1234567890' }
    end

    trait :with_webhook do
      webhook_secret { 'whsec_test_1234567890' }
    end
  end
end
