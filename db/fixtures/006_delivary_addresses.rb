DelivaryAddress.seed do |s|
  s.id = 'b2f19aed-da23-44c7-b93a-b71c9f76cdb8'
  s.tenant_id = 'sample'
  s.user_id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.is_default = true
  s.zip_code = '151-0033'
  s.prefecture_code = '13'
  s.city = '世田谷区'
  s.address_1 = '代田１丁目１−１'
  s.address_2 = '代田ビル 101号室'
end

DelivaryAddress.seed do |s|
  s.id = '12eca170-a90d-4f5e-9f67-ebe189900773'
  s.tenant_id = 'sample'
  s.user_id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.is_default = false
  s.zip_code = '151-0033'
  s.prefecture_code = '13'
  s.city = '世田谷区'
  s.address_1 = '代田2丁目2-2'
  s.address_2 = 'フェミール代田 101号室'
end
