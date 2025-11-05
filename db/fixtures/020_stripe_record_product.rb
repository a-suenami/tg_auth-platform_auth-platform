# seed stripe record products
StripeRecord::Product.seed do |s|
  s.id = '0f9cfedd-6b48-467b-883b-4b8d78365f55'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_ShcZgbY7KQke1Y'
  s.name = '段階的プラン-ベーシック'
  s.deleted = false
end

StripeRecord::Product.seed do |s|
  s.id = '9238f89a-fb76-4291-9277-59b08220edfc'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_ShcbyIipAk4Y31'
  s.name = '段階的プラン-プレミアム'
  s.deleted = false
end

StripeRecord::Product.seed do |s|
  s.id = '3ba4fd32-6a56-4006-bc25-3d49677bb404'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_ShccFNDqCTCoiZ'
  s.name = '段階的プラン-プラチナ'
  s.deleted = false
end

StripeRecord::Product.seed do |s|
  s.id = '2db19b1a-85f8-49a2-a0f7-9143d7a96c4b'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_T43sgJmnp7ns6M'
  s.name = 'メンバーA専用'
  s.deleted = false
end

StripeRecord::Product.seed do |s|
  s.id = '8c2cefa4-b35c-417e-8bb6-8bfe2ca6c699'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_TIGeGMU8h4zshL'
  s.name = 'メンバーB専用'
  s.deleted = false
end

StripeRecord::Product.seed do |s|
  s.id = 'a683e056-c6f2-41ea-b9d4-9b7bb771d89b'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_Sj1nLIOBX4oVR9'
  s.name = '段階的プラン-デイリープレミアム(テスト用プラン)'
  s.deleted = true
end

StripeRecord::Product.seed do |s|
  s.id = '06b7782c-a6d9-4902-8251-61d815320d35'
  s.tenant_id = 'sample'
  s.remote_id = 'prod_QcNDKBC7iBfLD8'
  s.name = 'サブスクBA'
  s.deleted = false
end
