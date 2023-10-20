# typed: false

FactoryBot.define do
  factory :tenant do
    id { 'twogate' }
    name { 'TwoGate' }
    cookie_domain_remove_length { 0 }
  end
end
