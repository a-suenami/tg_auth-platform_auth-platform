# seed users
User.seed do |s|
  s.uid = SecureRandom.uuid
  s.tenant_id = 'sample'
  s.email = 'test1@example.com'
  s.password = 'password'
end

User.seed do |s|
  s.uid = SecureRandom.uuid
  s.tenant_id = 'sample'
  s.email = 'test2@example.com'
  s.password = 'password'
end

# seed users
User.seed do |s|
  s.uid = SecureRandom.uuid
  s.tenant_id = 'twogate'
  s.email = 'twogate-test1@example.com'
  s.password = 'password'
end

User.seed do |s|
  s.uid = SecureRandom.uuid
  s.tenant_id = 'twogate'
  s.email = 'twogate-test2@example.com'
  s.password = 'password'
end
