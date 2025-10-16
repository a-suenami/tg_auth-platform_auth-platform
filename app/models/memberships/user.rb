# typed: strict

class Memberships::User < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__users'

  belongs_to :tenant
  belongs_to :user, class_name: '::User', inverse_of: :membership_users
  belongs_to :membership
  belongs_to :membership_group, class_name: 'Memberships::Group', optional: true
  belongs_to :membership_contract, class_name: 'Memberships::Contract', optional: true

  validates :user_id, uniqueness: { scope: [:tenant_id, :membership_id] }
end
