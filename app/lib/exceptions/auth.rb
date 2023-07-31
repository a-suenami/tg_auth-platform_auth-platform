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

    class AccountLocked < BaseError
      sig { returns(Symbol) }
      def code
        :account_locked
      end

      sig { returns(String) }
      def message
        '一定回数続けてログインに失敗したため、アカウントをロックしました。解除するにはご登録のメールアドレスに送付される案内をご確認いただくか、しばらく時間を開けてお試しください。'
      end
    end
  end
end
