# typed: strict
# frozen_string_literal: true

module UserTag
  class CreateService
    extend T::Sig

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(params:, admin:)
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      user_tag = nil

      ActiveRecord::Base.transaction do
        user_tag = ::UserTag.new(@params)
        user_tag.created_by = @admin
        user_tag.save!
      end

      { success: true, user_tag: user_tag }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_tag: e.record, errors: e.record.errors }
    end

    sig { params(params: T::Hash[Symbol, T.untyped], admin: Admin).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(params:, admin:)
      new(params: params, admin: admin).call
    end
  end
end
