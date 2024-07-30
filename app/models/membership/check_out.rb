# typed: strict

class Membership
  class CheckOut < ApplicationRecord
    extend T::Sig

    belongs_to :user
    has_many :check_out_items, dependent: :destroy, class_name: 'Membership::CheckOutItem'
    has_many :plans, through: :check_out_items, class_name: 'Membership::Plan'
  end
end
