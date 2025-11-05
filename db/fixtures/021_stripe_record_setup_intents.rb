# seed stripe record setup intents
StripeRecord::SetupIntent.seed do |s|
  s.id = 'ac0ea838-15c1-4f51-9fd1-bea7977e1d15'
  s.tenant_id = 'sample'
  s.user_id = '04df2296-8d2c-4d78-8e74-334ad06ac7cc'
  s.api_key_account_id = '02ff0a8c-9e4d-49f5-b52b-cc7d5a82e904'
  s.remote_id = 'seti_1SLhWxLtOmpZVCAzwNO572ZP'
  s.client_secret = 'seti_1SLhWxLtOmpZVCAzwNO572ZP_secret_TII7VVZmainHyCUfFDRPDROphoG3lXY'
  s.status = 'succeeded'
  s.usage = 'off_session'
  s.payment_method_id = 'pm_1SLha9LtOmpZVCAzUfcJbtMD'
  s.activated_at = Time.zone.parse('2025-10-24 18:46:58')
end
