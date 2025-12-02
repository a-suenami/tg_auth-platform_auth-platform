# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class UpdateService
    extend T::Sig

    sig { params(user_auto_tagging: ::UserAutoTagging, params: T::Hash[Symbol, T.untyped], admin: Admin).void }
    def initialize(user_auto_tagging:, params:, admin:)
      @user_auto_tagging = user_auto_tagging
      @params = params
      @admin = admin
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_auto_tagging.updated_by = @admin
        @user_auto_tagging.update!(@params)
      end

      { success: true, user_auto_tagging: @user_auto_tagging }
    rescue ActiveRecord::RecordInvalid => e
      { success: false, user_auto_tagging: e.record, errors: e.record.errors }
    end

    sig do
      params(
        user_auto_tagging: ::UserAutoTagging,
        params: T::Hash[Symbol, T.untyped],
        admin: Admin
      ).returns(T::Hash[Symbol, T.untyped])
    end
    def self.call(user_auto_tagging:, params:, admin:)
      new(user_auto_tagging: user_auto_tagging, params: params, admin: admin).call
    end
  end
end
