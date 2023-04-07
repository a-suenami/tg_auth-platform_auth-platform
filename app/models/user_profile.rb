# typed: strict

class UserProfile < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :user, inverse_of: :user_profile
end
