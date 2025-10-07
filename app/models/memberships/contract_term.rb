# typed: strict

class Memberships::ContractTerm < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__contract_terms'

  belongs_to :tenant
  belongs_to :user, class_name: '::User'
  belongs_to :contract, class_name: 'Memberships::Contract'
  belongs_to :membership_plan, class_name: 'Memberships::Plan'
end
