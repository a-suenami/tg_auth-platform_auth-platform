# seed users
Users::LinkedApplication.seed do |s|
  s.id = '7354446c-bab9-494e-aa9e-4a803deaf161'
  s.tenant_id = 'sample'
  s.user_id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.oauth_application_id = '40ce3073-75a6-4c47-8ebd-6a4fde3f81be'
  s.last_linked_at = Time.zone.now
  s.scopes = 'uid email name profile contact delivery_address openid'
end

Users::LinkedApplication.seed do |s|
  s.id = '685fb6d8-e8ef-4aa2-a7b0-f767d100652f'
  s.tenant_id = 'sample'
  s.user_id = '9a7e3bd7-d340-4447-a139-565d58371c7d'
  s.oauth_application_id = '40ce3073-75a6-4c47-8ebd-6a4fde3f81be'
  s.last_linked_at = Time.zone.now
  s.scopes = 'uid email name profile contact delivery_address openid'
end

Users::LinkedApplication.seed do |s|
  s.id = 'b88af9d6-d287-4d29-8b21-46a19ea83a13'
  s.tenant_id = 'sample'
  s.user_id = 'bbfde205-4fcb-40c8-9bcb-1c821c126ce1'
  s.oauth_application_id = '51667e97-1eea-4ad2-b60e-e59d24a2cf43'
  s.last_linked_at = Time.zone.now
  s.scopes = 'uid email name profile contact delivery_address openid'
end

Users::LinkedApplication.seed do |s|
  s.id = 'a1e5ad0c-00f5-40b4-8323-dc5ff528ef91'
  s.tenant_id = 'sample'
  s.user_id = 'f92a0891-c5ac-484a-b509-605a2ac54a73'
  s.oauth_application_id = '51667e97-1eea-4ad2-b60e-e59d24a2cf43'
  s.last_linked_at = Time.zone.now
  s.scopes = 'uid email name profile contact delivery_address openid'
end
