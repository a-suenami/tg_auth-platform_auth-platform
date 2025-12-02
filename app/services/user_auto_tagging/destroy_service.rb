# typed: strict
# frozen_string_literal: true

module UserAutoTagging
  class DestroyService
    extend T::Sig

    sig { params(user_auto_tagging: ::UserAutoTagging).void }
    def initialize(user_auto_tagging:)
      @user_auto_tagging = user_auto_tagging
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_auto_tagging.destroy!
      end

      { success: true }
    rescue ActiveRecord::RecordNotDestroyed => e
      { success: false, errors: e.record.errors }
    end

    sig { params(user_auto_tagging: ::UserAutoTagging).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(user_auto_tagging:)
      new(user_auto_tagging: user_auto_tagging).call
    end
  end
end
