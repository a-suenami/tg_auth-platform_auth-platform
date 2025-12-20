# typed: strict

class DeliveryUserTag < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :user_tag

  validates :delivery_id, uniqueness: { scope: :user_tag_id }
end
