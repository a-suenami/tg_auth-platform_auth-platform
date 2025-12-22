
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

  if StripeRecord::APIKey.find_by(id: '1eddc642-515c-45cd-849d-d0ae5ce10c7a').nil?
    api_key = StripeRecord::APIKey.new(
      id: '1eddc642-515c-45cd-849d-d0ae5ce10c7a',
      tenant_id: 'twogate',
      display_name: 'twogate',
      publishable_key: 'pk_test_51SCSSVLMzzM6d4Y54nO6wZMfn2eB9XbFzpwU2BAQoHc0wkX5chNiuJPR67EzztOWMVIlHJ4KwT5h0SXeZqZXynht00xXNtEKCK',
      secret_key: 'sk_test_51SCSSVLMzzM6d4Y5X8lrRbpIVyvgcw2KOz9Ihh1k9a6tbHKjqrqMmWEerpTb1iRE5n2iAp3xx0h9dzIK34OnIXwN00PVHTc0j2'
    )
    api_key.build_account(
      id: 'bc19444d-1850-493a-a5ed-b1fb16d926ec',
      tenant_id: 'twogate',
      remote_id: 'acct_1SCSSVLMzzM6d4Y5',
      display_name: 'twogate'
    )
    api_key.save!

    connect_account = StripeRecord::Account.new(
      id: 'a08ca801-7c33-4062-8841-8f7d614f270a',
      tenant_id: 'twogate',
      remote_id: 'acct_1SI21nQ2OScTxrr1',
      controlling_platform: api_key.account,
      display_name: 'twogate'
    )
    connect_account.save!


    Tenant::StripeAccount.seed do |s|
      s.id = 'e04cb712-1e8b-49a2-a2e3-23502243dcac'
      s.tenant_id = 'twogate'
      s.stripe_account_id = connect_account.id
      s.tax_rate_id = nil
      s.charge_type = nil
      s.fee_rate = nil
    end
  end
end
