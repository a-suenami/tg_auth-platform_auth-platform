# typed: strict

class Ruler < ApplicationRecord
  extend T::Sig
  include Auth0Connectable
end
