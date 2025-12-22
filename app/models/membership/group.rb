# typed: strict

class Membership::Group < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant

  has_many :memberships, class_name: 'Membership', dependent: :destroy, inverse_of: :membership_group

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true
end
