# seed users
User.seed do |s|
  s.id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.tenant_id = 'sample'
  s.email = 'test1@example.com'
  s.password = 'password'
  s.enabled = true
  s.email_verified = true
end

User.seed do |s|
  s.id = '9a7e3bd7-d340-4447-a139-565d58371c7d'
  s.tenant_id = 'sample'
  s.email = 'test2@example.com'
  s.password = 'password'
  s.enabled = true
  s.email_verified = true
end

# seed users
User.seed do |s|
  s.id = 'bbfde205-4fcb-40c8-9bcb-1c821c126ce1'
  s.tenant_id = 'twogate'
  s.email = 'twogate-test1@example.com'
  s.password = 'password'
  s.enabled = true
  s.email_verified = true
end

User.seed do |s|
  s.id = 'f92a0891-c5ac-484a-b509-605a2ac54a73'
  s.tenant_id = 'twogate'
  s.email = 'twogate-test2@example.com'
  s.password = 'password'
  s.enabled = true
  s.email_verified = true
end

User.seed do |s|
  s.id = '04df2296-8d2c-4d78-8e74-334ad06ac7cc'
  s.tenant_id = 'sample'
  s.email = 'sakata+1@twogate.com'
  s.password_digest = '$2a$12$qoBvSEWhOGWY93QJfyMwtOTWWbYc8ISN1VskGt49Ib4jPEqYVJO26'
  s.enabled = true
  s.phone_number = nil
  s.sms_verified = false
  s.email_verified = true
  s.suppress_sms_verification = false
  s.deleted = false
  s.deleted_at = nil
  s.password_reset_code = nil
  s.captcha_score = nil
  s.payment_provider = 'stripe'
  s.payment_customer_id = 'cus_TII7mZlaM5cUfS'
  s.default_payment_method = nil
end
