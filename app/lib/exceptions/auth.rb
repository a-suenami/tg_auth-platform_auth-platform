# typed: strict

module Exceptions
  module Auth
    class BaseError < Exceptions::BaseError; end

    class AuthError < BaseError
      sig { returns(Symbol) }
      def code
        :auth_error
      end

      sig { returns(String) }
      def message
        '認証に失敗しました'
      end
    end

    class InvalidEmail < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_email
      end

      sig { returns(String) }
      def message
        'emailの形式が不正です'
      end
    end
  end
end
