UserProfile.seed do |s|
  s.tenant_id = 'sample'
  s.user_id = 'a07348fe-26b8-417b-ae18-aaf6851f7651'
  s.first_name = '太郎'
  s.last_name = '山田'
  s.first_name_kana = 'タロウ'
  s.last_name_kana = 'ヤマダ'
  s.birth_date = Date.parse('1990-01-01')
  s.gender = 'male'
end

UserProfile.seed do |s|
  s.tenant_id = 'sample'
  s.user_id = '9a7e3bd7-d340-4447-a139-565d58371c7d'
  s.first_name = '一郎'
  s.last_name = '佐藤'
  s.first_name_kana = 'イチロウ'
  s.last_name_kana = 'サトウ'
  s.birth_date = Date.parse('1990-02-01')
  s.gender = 'male'
end

UserProfile.seed do |s|
  s.tenant_id = 'sample'
  s.user_id = 'bbfde205-4fcb-40c8-9bcb-1c821c126ce1'
  s.first_name = '次郎'
  s.last_name = '鈴木'
  s.first_name_kana = 'ジロウ'
  s.last_name_kana = 'スズキ'
  s.birth_date = Date.parse('1990-03-01')
  s.gender = 'male'
end

UserProfile.seed do |s|
  s.tenant_id = 'sample'
  s.user_id = 'f92a0891-c5ac-484a-b509-605a2ac54a73'
  s.first_name = '三郎'
  s.last_name = '高橋'
  s.first_name_kana = 'サブロウ'
  s.last_name_kana = 'タカハシ'
  s.birth_date = Date.parse('1990-04-01')
  s.gender = 'male'
end
