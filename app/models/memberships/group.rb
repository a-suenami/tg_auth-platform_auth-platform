# typed: strict

class Memberships::Group < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__groups'

  belongs_to :tenant

  has_many :membership_users, class_name: 'Memberships::User', dependent: :nullify

  validates :name, presence: true, uniqueness: { scope: :tenant_id }
  validates :display_name, presence: true
end
