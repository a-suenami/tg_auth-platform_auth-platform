# typed: strict

class TenantSetting < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
end
