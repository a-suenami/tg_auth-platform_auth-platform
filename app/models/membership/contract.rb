# typed: strict

class Membership::Contract < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user, class_name: '::User'

  # transactionの中でもphaseがcurrentのものを取得する
  has_many :contract_terms, class_name: 'Membership::ContractTerm', dependent: :destroy, inverse_of: :membership_contract
  has_one :current_contract_term, -> { where(status: :current) }, class_name: 'Membership::ContractTerm', dependent: :nullify, inverse_of: :membership_contract, foreign_key: :membership_contract_id
  has_one :upcoming_contract_term, -> { where(status: :upcoming) }, class_name: 'Membership::ContractTerm', dependent: :nullify, inverse_of: :membership_contract, foreign_key: :membership_contract_id
  has_many :membership_users, class_name: 'Membership::User', dependent: :destroy, inverse_of: :membership_contract
  has_many :payment_transactions, class_name: 'Payment::Transaction', dependent: :destroy, inverse_of: :membership_contract
  has_one :payment_subscription, class_name: 'Payment::Subscription', dependent: :destroy, inverse_of: :membership_contract

  enumerize :status, in: {
    active: 'active',
    pending: 'pending',
    expired: 'expired',
    canceled: 'canceled',
  }
end
