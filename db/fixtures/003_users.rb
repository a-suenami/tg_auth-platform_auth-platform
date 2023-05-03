# seed users
User.seed do |s|
  s.id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.tenant_id = 'sample'
  s.email = 'test1@example.com'
  s.password = 'password'
end

User.seed do |s|
  s.id = '9a7e3bd7-d340-4447-a139-565d58371c7d'
  s.tenant_id = 'sample'
  s.email = 'test2@example.com'
  s.password = 'password'
end

# seed users
User.seed do |s|
  s.id = 'bbfde205-4fcb-40c8-9bcb-1c821c126ce1'
  s.tenant_id = 'twogate'
  s.email = 'twogate-test1@example.com'
  s.password = 'password'
end

User.seed do |s|
  s.id = 'f92a0891-c5ac-484a-b509-605a2ac54a73'
  s.tenant_id = 'twogate'
  s.email = 'twogate-test2@example.com'
  s.password = 'password'
end
