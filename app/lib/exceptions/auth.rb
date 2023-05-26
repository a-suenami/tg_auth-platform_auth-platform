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

    class AccessTokenExpired < BaseError
      sig { returns(Symbol) }
      def code
        :access_token_expired
      end

      sig { returns(String) }
      def message
        'access tokenの有効期限が切れています'
      end
    end
  end
end
