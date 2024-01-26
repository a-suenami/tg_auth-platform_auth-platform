# typed: strict

module Exceptions
  module Users
    class BaseError < Exceptions::BaseError; end

    class InvalidEmail < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_email
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.users.invalid_email'
      end
    end

    class InvalidCode < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_code
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.users.invalid_code'
      end
    end

    class ExpiredEmailVerificationCode < BaseError
      sig { returns(Symbol) }
      def code
        :expired_email_verification_code
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.users.expired_email_verification_code'
      end
    end

    class EmailVerificationCodeAttemptsIsOver < BaseError
      sig { returns(Symbol) }
      def code
        :email_verification_code_attempts_is_over
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.users.email_verification_code_attempts_is_over'
      end
    end
  end
end
