Tenant.seed do |s|
  s.id   = 'sample'
  s.name = 'SAMPLE'
  # TODO: 坂田の開発用サーバのdomainなので、他の人がjoinするまでに直す
  s.domain = 'sample.localhost.com'
end

Tenant.seed do |s|
  s.id   = 'twogate'
  s.name = 'TWOGATE'
  # TODO: 坂田の開発用サーバのdomainなので、他の人がjoinするまでに直す
  s.domain = 'twogate.localhost.com'
end
