# typed: strict
# frozen_string_literal: true

module UserTag
  class UpdateService
    extend T::Sig

    sig { params(user_tag: ::UserTag, params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(user_tag:, params:, admin:)
      @user_tag = user_tag
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_tag.updated_by = @admin
        @user_tag.update!(@params)
      end

      { success: true, user_tag: @user_tag }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_tag: e.record, errors: e.record.errors }
    end

    sig do
      params(
        user_tag: ::UserTag,
        params: T::Hash[Symbol, T.untyped],
        admin: Admin
      ).returns(T::Hash[Symbol, T.untyped])
    end
    def self.call(user_tag:, params:, admin:)
      new(user_tag: user_tag, params: params, admin: admin).call
    end
  end
end
