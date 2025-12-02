# typed: strict
# frozen_string_literal: true

module UserTag
  class DestroyService
    extend T::Sig

    sig { params(user_tag: ::UserTag).void }
    def initialize(user_tag:)
      @user_tag = user_tag
    end

    sig { returns(T::Hash[Symbol, T.untyped]) }
    def call
      ActiveRecord::Base.transaction do
        @user_tag.destroy!
      end

      { success: true }
    rescue ActiveRecord::RecordNotDestroyed => e
      { success: false, errors: e.record.errors }
    end

    sig { params(user_tag: ::UserTag).returns(T::Hash[Symbol, T.untyped]) }
    def self.call(user_tag:)
      new(user_tag: user_tag).call
    end
  end
end
