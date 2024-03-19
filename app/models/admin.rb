# typed: strict

class Admin < ApplicationRecord
  extend T::Sig
  include Multitenancy
  include Auth0Connectable
end
