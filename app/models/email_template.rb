# typed: strict

class EmailTemplate < ApplicationRecord
  extend T::Sig
  include Multitenancy
end
