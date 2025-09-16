# typed: strict

class Memberships::Contract < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__contracts'

  belongs_to :tenant
  belongs_to :user, class_name: '::User'

  has_many :billing_profiles, class_name: 'Memberships::BillingProfile', dependent: :destroy, inverse_of: :membership_contract
  # billing_profileの中でもphaseがcurrentのものを取得する
  has_one :current_billing_profile, -> { where(phase: :current) }, class_name: 'Memberships::BillingProfile', dependent: :nullify, inverse_of: :contract
  has_one :upcoming_billing_profile, -> { where(phase: :upcoming) }, class_name: 'Memberships::BillingProfile', dependent: :nullify, inverse_of: :contract


  enumerize :status, in: {
    active: 'active',
    pending: 'pending',
    expired: 'expired',
    canceled: 'canceled',
  }
end
