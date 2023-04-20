# typed: strict

class UserProfile < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :user, inverse_of: :user_profile

  sig { returns(String) }
  def name
    "#{last_name} #{first_name} "
  end

  # 誕生日から年代を計算する
  sig { returns(Integer) }
  def age_range
    return 0 if birth_date.nil?

    age = Time.zone.today.year - T.must(birth_date).year
    age -= 1 if Time.zone.today < T.must(birth_date) + age.years
    age
  end
end
