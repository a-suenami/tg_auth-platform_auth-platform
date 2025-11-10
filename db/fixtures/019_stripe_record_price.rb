# seed stripe record prices
StripeRecord::Price.seed do |s|
  s.id = 'f9b3525f-da68-44ab-aa78-907168606b5a'
  s.tenant_id = 'sample'
  s.product_id = '3ba4fd32-6a56-4006-bc25-3d49677bb404'
  s.remote_id = 'price_1RmDNmLtOmpZVCAz69g7JZKk'
  s.name = '段階的プラン-プラチナ(年額)'
  s.amount = 14400
  s.interval = 'year'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'year'
end

StripeRecord::Price.seed do |s|
  s.id = '0e3b9d5b-d7ca-4bdc-8b0a-db33ec3ee744'
  s.tenant_id = 'sample'
  s.product_id = '3ba4fd32-6a56-4006-bc25-3d49677bb404'
  s.remote_id = 'price_1RmDMzLtOmpZVCAz7W9gMa2r'
  s.name = '段階的プラン-プラチナ(月額)'
  s.amount = 1200
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end

StripeRecord::Price.seed do |s|
  s.id = 'daa21722-829c-493c-aa18-83a881d0e404'
  s.tenant_id = 'sample'
  s.product_id = '2db19b1a-85f8-49a2-a0f7-9143d7a96c4b'
  s.remote_id = 'price_1S7vkMLtOmpZVCAzqJgclopC'
  s.name = 'メンバーA専用月額'
  s.amount = 1000
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end

StripeRecord::Price.seed do |s|
  s.id = 'e214d49b-313b-4bb3-9d63-8e4450c38fb3'
  s.tenant_id = 'sample'
  s.product_id = '8c2cefa4-b35c-417e-8bb6-8bfe2ca6c699'
  s.remote_id = 'price_1SLg7WLtOmpZVCAzVnmW23Rw'
  s.name = nil
  s.amount = 500
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end

StripeRecord::Price.seed do |s|
  s.id = '26728506-1abd-4fc2-8247-f468e3755cae'
  s.tenant_id = 'sample'
  s.product_id = '0f9cfedd-6b48-467b-883b-4b8d78365f55'
  s.remote_id = 'price_1SLge4LtOmpZVCAzDAu2niHn'
  s.name = '段階的プラン ベーシック 日次(テスト用)'
  s.amount = 100
  s.interval = 'day'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'day'
end

StripeRecord::Price.seed do |s|
  s.id = '715ca933-a1d1-4130-b94d-19c4fcd6f9bd'
  s.tenant_id = 'sample'
  s.product_id = '0f9cfedd-6b48-467b-883b-4b8d78365f55'
  s.remote_id = 'price_1RmDLJLtOmpZVCAzUuKdop96'
  s.name = '段階的プラン-ベーシック(年額)'
  s.amount = 6000
  s.interval = 'year'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'year'
end

StripeRecord::Price.seed do |s|
  s.id = 'c4957a9e-0ab2-4ca9-9e40-0cc02c5f7a88'
  s.tenant_id = 'sample'
  s.product_id = '0f9cfedd-6b48-467b-883b-4b8d78365f55'
  s.remote_id = 'price_1RmDKiLtOmpZVCAz43q0JTak'
  s.name = '段階的プラン-ベーシック(月額)'
  s.amount = 500
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end

StripeRecord::Price.seed do |s|
  s.id = '27d0fe7d-9840-4e59-baad-c282944127d8'
  s.tenant_id = 'sample'
  s.product_id = 'a683e056-c6f2-41ea-b9d4-9b7bb771d89b'
  s.remote_id = 'price_1RnZjoLtOmpZVCAzayT4SfoH'
  s.name = nil
  s.amount = 200
  s.interval = 'day'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = true
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'day'
end

StripeRecord::Price.seed do |s|
  s.id = 'fb161c2b-905a-41fe-92c2-852e4ddbc9df'
  s.tenant_id = 'sample'
  s.product_id = '9238f89a-fb76-4291-9277-59b08220edfc'
  s.remote_id = 'price_1SLgedLtOmpZVCAz5lLbPSiv'
  s.name = '段階的プラン プレミアム 日次(テスト)'
  s.amount = 200
  s.interval = 'day'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'day'
end

StripeRecord::Price.seed do |s|
  s.id = '34ec63de-26c5-4109-ae25-89ede3c55c31'
  s.tenant_id = 'sample'
  s.product_id = '9238f89a-fb76-4291-9277-59b08220edfc'
  s.remote_id = 'price_1RmDMPLtOmpZVCAzHiCggm0m'
  s.name = '段階的プラン-プレミアム(年額)'
  s.amount = 12000
  s.interval = 'year'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'year'
end

StripeRecord::Price.seed do |s|
  s.id = '58ef2f10-7224-49d6-b492-322f60c4dd98'
  s.tenant_id = 'sample'
  s.product_id = '9238f89a-fb76-4291-9277-59b08220edfc'
  s.remote_id = 'price_1RmDM3LtOmpZVCAzZkR0ORC3'
  s.name = '段階的プラン-プレミアム(月額)'
  s.amount = 1000
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end

StripeRecord::Price.seed do |s|
  s.id = '0d53efe4-cbe7-49fb-a928-d0caf5ba28a7'
  s.tenant_id = 'sample'
  s.product_id = '06b7782c-a6d9-4902-8251-61d815320d35'
  s.remote_id = 'price_1Pl8T9LtOmpZVCAzO9jTtmlY'
  s.name = 'ABセットパック年額'
  s.amount = 4000
  s.interval = 'year'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'year'
end

StripeRecord::Price.seed do |s|
  s.id = 'd4a195ec-81a6-447a-9b42-adbb59444a70'
  s.tenant_id = 'sample'
  s.product_id = '06b7782c-a6d9-4902-8251-61d815320d35'
  s.remote_id = 'price_1Pl8StLtOmpZVCAzOt8p6T5u'
  s.name = 'ABセットパック 月額'
  s.amount = 400
  s.interval = 'month'
  s.interval_count = 1
  s.trial_period_days = nil
  s.deleted = false
  s.position = 1000
  s.displayed = true
  s.interval_unit = 'month'
end
