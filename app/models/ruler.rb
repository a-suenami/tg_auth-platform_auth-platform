# typed: strict

class Ruler < ApplicationRecord
  extend T::Sig
  include Multitenancy
end
