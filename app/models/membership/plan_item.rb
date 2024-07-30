# typed: strict

class Membership
  class PlanItem < ApplicationRecord
    extend T::Sig

    belongs_to :membership
    belongs_to :plan, class_name: 'Membership::Plan'
  end
end
