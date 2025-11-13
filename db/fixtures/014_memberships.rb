# seed memberships
Membership.seed do |s|
  s.id = 'e9ff4a76-5010-42a0-b6e4-1e9ed41a7be2'
  s.tenant_id = 'sample'
  s.membership_group_id = nil
  s.name = 'membershipA'
  s.display_name = 'メンバーシップA'
  s.position = 4
  s.tier = 1
end

Membership.seed do |s|
  s.id = 'ab18f39f-af16-45b2-a902-53322907e739'
  s.tenant_id = 'sample'
  s.membership_group_id = nil
  s.name = 'membershipB'
  s.display_name = 'メンバーシップB'
  s.position = 5
  s.tier = 1
end

Membership.seed do |s|
  s.id = '92609f1b-3f05-4beb-b0c3-fac00a187d57'
  s.tenant_id = 'sample'
  s.membership_group_id = nil
  s.name = 'Debug'
  s.display_name = '段階的プラン テスト用'
  s.position = 6
  s.tier = 4
end

Membership.seed do |s|
  s.id = '542c871e-b0f3-43ae-a2f3-022158fa54e5'
  s.tenant_id = 'sample'
  s.membership_group_id = 'fcf46391-fa56-4117-9786-010308f3153e'
  s.name = 'Basic'
  s.display_name = '段階的メンバーシップ ベーシック'
  s.position = 1
  s.tier = 3
end

Membership.seed do |s|
  s.id = '59d61af2-0f15-4301-a207-958829e87f20'
  s.tenant_id = 'sample'
  s.membership_group_id = 'fcf46391-fa56-4117-9786-010308f3153e'
  s.name = 'Premium'
  s.display_name = '段階的メンバーシップ プレミアム'
  s.position = 2
  s.tier = 2
end

Membership.seed do |s|
  s.id = 'd4cdb65f-2f94-448a-95c8-a4e9cc4c2c85'
  s.tenant_id = 'sample'
  s.membership_group_id = 'fcf46391-fa56-4117-9786-010308f3153e'
  s.name = 'Platinum'
  s.display_name = '段階的メンバーシップ プラチナ'
  s.position = 3
  s.tier = 1
end
