
if Settings&.stripe&.default_key_for_develop&.publishable_key&.present?
  if StripeRecord::APIKey.find_by(id: '6da7f801-b36c-46b7-bba2-c759a883dd0f').nil?
    # Sampleテナント用
    api_key = StripeRecord::APIKey.new(
      id: '6da7f801-b36c-46b7-bba2-c759a883dd0f',
      tenant_id: 'sample',
      remote_id: 'acct_1PiwCqLtOmpZVCAz',
      display_name: 'sample',
      publishable_key: Settings.stripe.default_key_for_develop.publishable_key,
      secret_key: Settings.stripe.default_key_for_develop.secret_key
    )
    api_key.build_account(
      id: '02ff0a8c-9e4d-49f5-b52b-cc7d5a82e904',
      tenant_id: 'sample',
      remote_id: 'acct_1PiwCqLtOmpZVCAz',
      display_name: 'sample'
    )
    api_key.save!

    Tenant::StripeAccount.seed do |s|
      s.id = 'bce91857-ff0c-4bd2-8dce-cf5b08c1ad71'
      s.tenant_id = 'sample'
      s.stripe_account_id = api_key.account.id
      s.tax_rate_id = nil
      s.charge_type = nil
      s.fee_rate = nil
    end
  end
end
