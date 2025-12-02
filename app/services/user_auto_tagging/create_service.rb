# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class CreateService
    extend T::Sig

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(params:, admin:)
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      user_auto_tagging = nil

      ActiveRecord::Base.transaction do
        user_auto_tagging = ::UserAutoTagging.new(@params)
        user_auto_tagging.created_by = @admin
        user_auto_tagging.save!
      end

      { success: true, user_auto_tagging: user_auto_tagging }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_auto_tagging: e.record, errors: e.record.errors }
    end

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(params:, admin:)
      new(params: params, admin: admin).call
    end
  end
end
