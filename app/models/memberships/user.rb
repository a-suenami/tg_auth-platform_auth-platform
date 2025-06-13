# typed: strict

class Memberships::User < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__users'

  belongs_to :tenant
  belongs_to :user
  belongs_to :membership
  belongs_to :membership_group, class_name: 'Memberships::Group', optional: true

  validates :user_id, uniqueness: { scope: [:tenant_id, :membership_id] }
end
