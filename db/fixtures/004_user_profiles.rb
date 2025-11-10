UserProfile.seed do |s|
  s.id = '49ffdddf-29df-46c5-8021-3e1599ea9339'
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
  s.id = '25539345-7781-49a8-9dc2-88dc0f820246'
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
  s.id = 'f6bf44ed-5ced-46ac-84c8-ac27fc236ed0'
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
  s.id = '969a82bb-e37e-44ee-8fec-f44a7b43bd27'
  s.tenant_id = 'sample'
  s.user_id = 'f92a0891-c5ac-484a-b509-605a2ac54a73'
  s.first_name = '三郎'
  s.last_name = '高橋'
  s.first_name_kana = 'サブロウ'
  s.last_name_kana = 'タカハシ'
  s.birth_date = Date.parse('1990-04-01')
  s.gender = 'male'
end

UserProfile.seed do |s|
  s.id = '538482da-b80f-403e-be70-e2420c8168ac'
  s.tenant_id = 'sample'
  s.user_id = '04df2296-8d2c-4d78-8e74-334ad06ac7cc'
  s.first_name = '健太'
  s.last_name = '霧島'
  s.first_name_kana = 'ケンタ'
  s.last_name_kana = 'キリシマ'
  s.birth_date = Date.parse('2000-01-01')
  s.gender = 'other'
end
