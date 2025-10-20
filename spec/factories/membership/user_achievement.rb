# typed: false

FactoryBot.define do
  factory :membership_user_achievement, class: 'Membership::UserAchievement' do
    tenant_id { create(:tenant).id }
    membership_plan { create(:membership_plan, tenant_id: self.tenant_id) }
    user { create(:user, tenant_id: self.tenant_id) }
    achievement_type { 'login_count' }
    achievement_value { rand(1..100) }
    achieved_at { Time.current }
  end
end
