# typed: false

FactoryBot.define do
  factory :tenant do
    id { 'twogate' }
    name { 'TwoGate' }
    set_parent_domain_cookie { true }
  end
end
