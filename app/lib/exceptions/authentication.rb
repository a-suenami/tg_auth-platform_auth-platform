# typed: strict

module Exceptions
  module Authentication
    class BaseError < Exceptions::BaseError; end

    class InvalidEmail < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_email
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.invalid_email'
      end
    end

    class InvalidCode < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_code
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.invalid_code'
      end
    end

    class ExpiredEmailVerificationCode < BaseError
      sig { returns(Symbol) }
      def code
        :expired_email_verification_code
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.expired_email_verification_code'
      end
    end

    class EmailVerificationCodeAttemptsIsOver < BaseError
      sig { returns(Symbol) }
      def code
        :email_verification_code_attempts_is_over
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.email_verification_code_attempts_is_over'
      end
    end

    class PasswordResetCodeInvalid < BaseError
      sig { returns(Symbol) }
      def code
        :password_reset_code_invalid
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.password_reset_code_invalid'
      end
    end

    class PasswordResetCodeUsed < BaseError
      sig { returns(Symbol) }
      def code
        :password_reset_code_used
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.password_reset_code_used'
      end
    end

    class PasswordResetCodeExpired < BaseError
      sig { returns(Symbol) }
      def code
        :password_reset_code_expired
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.password_reset_code_expired'
      end
    end

    class PasswordAlreadySet < BaseError
      sig { returns(Symbol) }
      def code
        :password_already_set
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.password_already_set'
      end
    end

    class PhoneNumberAlreadySet < BaseError
      sig { returns(Symbol) }
      def code
        :phone_number_already_set
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.phone_number_already_set'
      end
    end

    class SmsVerificationCodeAttemptsIsOver < BaseError
      sig { returns(Symbol) }
      def code
        :sms_verification_code_attempts_is_over
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.sms_verification_code_attempts_is_over'
      end
    end

    class SmsVerificationDisabled < BaseError
      sig { returns(Symbol) }
      def code
        :sms_verification_disabled
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.sms_verification_disabled'
      end
    end

    class PhoneNumberDuplicated < BaseError
      sig { returns(Symbol) }
      def code
        :phone_number_duplicated
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.phone_number_duplicated'
      end
    end

    class PhoneNumberInvaild < BaseError
      sig { returns(Symbol) }
      def code
        :phone_number_invaild
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.phone_number_invaild'
      end
    end

    class NoSmsSupportedCountry < BaseError
      sig { returns(Symbol) }
      def code
        :no_sms_supported_country
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.no_sms_supported_country'
      end
    end

    class SmsSendLimit < BaseError
      sig { returns(Symbol) }
      def code
        :sms_send_limit
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.authentication.sms_send_limit'
      end
    end
  end
end
