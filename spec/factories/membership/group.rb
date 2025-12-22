# typed: false

FactoryBot.define do
  factory :membership_group, class: 'Membership::Group' do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "group_#{n}" }
    sequence(:display_name) { |n| "グループ#{n}" }
    position { rand(0..100) }

    trait :with_leveled_memberships do
      after(:create) do |group|
        create(:membership, tenant_id: group.tenant_id, name: 'platinum', display_name: 'プラチナプラン', membership_group: group, position: 1, tier: 1)
        create(:membership, tenant_id: group.tenant_id, name: 'premium', display_name: 'プレミアムプラン', membership_group: group, position: 2, tier: 2)
        create(:membership, tenant_id: group.tenant_id, name: 'basic', display_name: 'ベーシックプラン', membership_group: group, position: 3, tier: 3)
      end
    end
  end
end
