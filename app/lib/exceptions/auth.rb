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
        I18n.t 'exceptions.auth.auth_error'
      end
    end

    class AccessTokenExpired < BaseError
      sig { returns(Symbol) }
      def code
        :access_token_expired
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.auth.access_token_expired'
      end
    end

    class AccountLocked < BaseError
      sig { returns(Symbol) }
      def code
        :account_locked
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.auth.account_locked'
      end
    end

    class RecaptchaTokenInvaild < BaseError
      sig { returns(Symbol) }
      def code
        :recaptcha_token_invaild
      end

      sig { returns(String) }
      def message
        'reCAPTCHAによりBOTによるアクセスと判定されました。しばらく時間をおいてお試しください。'
      end
    end
  end
end
