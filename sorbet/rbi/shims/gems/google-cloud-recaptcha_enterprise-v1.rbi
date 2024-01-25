# typed: strict

# ==============================================================================
# sorbet - rbi - shims - gems - google-cloud-recaptcha_enterprise-v1
# ==============================================================================
module Google
  module Cloud
    module RecaptchaEnterprise
      module V1
        module RecaptchaEnterpriseService
          class Client
            extend T::Sig

            sig { params(block: T.proc.params(credentials: T.untyped).void).void }
            def initialize(&block); end
          end
        end
      end
    end
  end
end
