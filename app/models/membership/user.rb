# typed: strict

class Membership
  class User < ApplicationRecord
    extend T::Sig

    belongs_to :user
    belongs_to :membership
  end
end
