# typed: strict

class Memberships::ContractTerm < ApplicationRecord
  extend T::Sig
  include Multitenancy

  self.table_name = 'memberships__contract_terms'

  belongs_to :tenant
  belongs_to :user, class_name: '::User'

end
