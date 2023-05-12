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
    end
  end
end
