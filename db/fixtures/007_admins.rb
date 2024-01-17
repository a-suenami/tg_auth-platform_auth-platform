Admin.seed do |s|
  s.id = 'c6d33a2c-9f4f-4669-a0be-3098e722aaff'
  s.name = 'Tenant Admin'
  s.tenant_id = 'sample'
  s.email = 'test-admin@example.com'
  s.uid = 'auth0|6440c74cdacb437dc2139682'
end

Admin.seed do |s|
  s.id = "5d2ebfa1-037f-4c43-b481-e25da2b7153c"
  s.name = 'Tenant Admin'
  s.tenant_id = 'sample'
  s.email = 'user@example.com'
  s.uid = 'auth0|65a78decd339da0835b7f8cc'
end
