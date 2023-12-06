# typed: strict

module Exceptions
  module Services
    module Users
      class BaseError < Exceptions::BaseError; end

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

      class InvalidCode < BaseError
        sig { returns(Symbol) }
        def code
          :invalid_code
        end

        sig { returns(String) }
        def message
          'codeが不正です'
        end
      end

      class ExpiredEmailVerificationCode < BaseError
        sig { returns(Symbol) }
        def code
          :expired_email_verification_code
        end

        sig { returns(String) }
        def message
          'codeの有効期限が切れています'
        end
      end

      class EmailVerificationCodeAttemptsIsOver < BaseError
        sig { returns(Symbol) }
        def code
          :email_verification_code_attempts_is_over
        end

        sig { returns(String) }
        def message
          'codeの試行回数が上限に達しました'
        end
      end

      class PasswordResetCodeInvalid < BaseError
        sig { returns(Symbol) }
        def code
          :password_reset_code_invalid
        end

        sig { returns(String) }
        def message
          'password reset codeが不正です'
        end
      end

      class PasswordResetCodeUsed < BaseError
        sig { returns(Symbol) }
        def code
          :password_reset_code_used
        end

        sig { returns(String) }
        def message
          'codeはすでに使用されています'
        end
      end

      class PasswordResetCodeExpired < BaseError
        sig { returns(Symbol) }
        def code
          :password_reset_code_expired
        end

        sig { returns(String) }
        def message
          'codeの有効期限が切れています'
        end
      end

      class PasswordAlreadySet < BaseError
        sig { returns(Symbol) }
        def code
          :password_already_set
        end

        sig { returns(String) }
        def message
          'パスワードはすでに設定済みです'
        end
      end

      class PhoneNumberAlreadySet < BaseError
        sig { returns(Symbol) }
        def code
          :phone_number_already_set
        end

        sig { returns(String) }
        def message
          '電話番号はすでに設定済みです'
        end
      end

      class SmsVerificationCodeAttemptsIsOver < BaseError
        sig { returns(Symbol) }
        def code
          :sms_verification_code_attempts_is_over
        end

        sig { returns(String) }
        def message
          'codeの試行回数が上限に達しました'
        end
      end

      class SmsVerificationDisabled < BaseError
        sig { returns(Symbol) }
        def code
          :sms_verification_disabled
        end

        sig { returns(String) }
        def message
          'SMS確認機能が無効です'
        end
      end

      class PhoneNumberDuplicated < BaseError
        sig { returns(Symbol) }
        def code
          :phone_number_duplicated
        end

        sig { returns(String) }
        def message
          'その電話番号はすでに使用されています。'
        end
      end

      class PhoneNumberInvaild < BaseError
        sig { returns(Symbol) }
        def code
          :phone_number_invaild
        end

        sig { returns(String) }
        def message
          '電話番号の形式が不正です'
        end
      end
    end
  end
end
