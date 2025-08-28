# typed: false

FactoryBot.define do
  factory :memberships__group, class: 'Memberships::Group' do
    tenant_id { create(:tenant).id }
    sequence(:name) { |n| "group_#{n}" }
    sequence(:display_name) { |n| "グループ#{n}" }
    position { rand(0..100) }
  end
end

