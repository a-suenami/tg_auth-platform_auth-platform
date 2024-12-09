Admin.seed do |s|
  s.id = 'c6d33a2c-9f4f-4669-a0be-3098e722aaff'
  s.name = 'Tenant Admin'
  s.tenant_id = 'sample'
  s.email = 'test-admin@example.com'
  s.uid = 'auth0|6756b91ab16b2779ba0c3da4'
end

Admin.seed do |s|
  s.id = "5d2ebfa1-037f-4c43-b481-e25da2b7153c"
  s.name = 'Tenant Admin'
  s.tenant_id = 'sample'
  s.email = 'user@example.com'
  s.uid = 'auth0|6756b934b16b2779ba0c3dc1'
end
