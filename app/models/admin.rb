# typed: strict

class Admin < ApplicationRecord
  extend T::Sig
  include Multitenancy
end
