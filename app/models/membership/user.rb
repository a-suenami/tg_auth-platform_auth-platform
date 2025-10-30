# typed: strict

class Membership::User < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user, class_name: '::User', inverse_of: :membership_users
  belongs_to :membership
  belongs_to :membership_group, class_name: 'Membership::Group', optional: true
  belongs_to :membership_contract, class_name: 'Membership::Contract', optional: true

  enumerize :status, in: {
    pending: 'pending',
    active: 'active',
    past_due: 'past_due', # 支払いが確認できていない。無効化状態
    closed: 'closed',
  }

  validates :user_id, uniqueness: { scope: [:tenant_id, :membership_id] }
end
