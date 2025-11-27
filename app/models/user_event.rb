# typed: strict
# frozen_string_literal: true

class UserEvent < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user
end
