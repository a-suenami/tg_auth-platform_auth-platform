# typed: strict

class Membership
  class CheckOutItem < ApplicationRecord
    extend T::Sig

    belongs_to :user
    belongs_to :check_out, class_name: 'Membership::CheckOut'
    belongs_to :plan, class_name: 'Membership::Plan'
  end
end
