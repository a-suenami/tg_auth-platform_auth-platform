# typed: false

FactoryBot.define do
  factory :memberships__user_achievement, class: 'Memberships::UserAchievement' do
    tenant_id { create(:tenant).id }
    membership_plan { create(:membership_plan) }
    user { create(:user) }
    achievement_type { 'login_count' }
    achievement_value { rand(1..100) }
    achieved_at { Time.current }
  end
end

