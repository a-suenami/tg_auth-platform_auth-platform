# typed: strict

class Tenant < ApplicationRecord
  has_many :booths
end
