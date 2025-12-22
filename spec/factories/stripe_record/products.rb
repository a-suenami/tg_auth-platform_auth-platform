# typed: false

FactoryBot.define do
  factory :stripe_record_product, class: 'StripeRecord::Product' do
    tenant_id { create(:tenant).id }

    sequence(:remote_id) { |n| "prod_#{n}" }
    sequence(:name) { |n| "product_#{n}" }
    deleted { false }

    trait :deleted do
      deleted { true }
    end

    trait :with_prices do
      after(:create) do |product|
        create_list(:stripe_record_price, 3, product: product, tenant_id: tenant_id)
      end
    end
  end
end
