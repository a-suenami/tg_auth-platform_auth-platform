# typed: strict
# frozen_string_literal: true

module Payment
  class Subscription < ApplicationRecord
    extend T::Sig
    include Multitenancy

    self.table_name = 'payment__subscriptions'

    belongs_to :tenant
    belongs_to :user, class_name: '::User'
  end
end
