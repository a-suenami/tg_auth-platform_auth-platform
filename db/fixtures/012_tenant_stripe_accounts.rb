
if Settings&.stripe&.default_key_for_develop&.publishable_key&.present?

  # 開発環境用にStripeのAPIキーをセットする
  if StripeRecord::APIKey.find_by(id: 'f4cfae0c-a7b6-48f9-9ecd-b61ff7517d44').nil?
    api_key = StripeRecord::APIKey.new(
      id: 'f4cfae0c-a7b6-48f9-9ecd-b61ff7517d44',
      remote_id: 'acct_1PiwCqLtOmpZVCAz',
      display_name: 'twogate',
      publishable_key: Settings.stripe.default_key_for_develop.publishable_key,
      secret_key: Settings.stripe.default_key_for_develop.secret_key
    )
    api_key.build_account(
      id: '3179439b-ef86-4188-b848-e915826d6c12',
      remote_id: 'acct_1PiwCqLtOmpZVCAz',
      display_name: 'twogate'
    )
    api_key.save!
  end


  Tenant::StripeAccount.seed do |s|
    s.id = '82ef2ba0-d71a-4c35-86f0-ae0217b64948'
    s.tenant_id = 'twogate'
    s.stripe_account_id = nil
    s.charge_type = nil
    s.fee_rate = nil
  end
end
