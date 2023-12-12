# typed: strict

# ==============================================================================
# sorbet - rbi - shims - gems - google-cloud-recaptcha_enterprise-v1
# ==============================================================================
module Google
  module Cloud
    module RecaptchaEnterprise
      module V1
        class CreateAssessmentRequest
          extend T::Sig

          sig do
            params(
              assessment: T.nilable(Google::Cloud::RecaptchaEnterprise::V1::Assessment),
              parent: T.nilable(String)
            ).void
          end
          def initialize(assessment: nil, parent: nil); end
        end

        module RecaptchaEnterpriseService
          class Client
            extend T::Sig

            sig { params(block: T.proc.params(credentials: T.untyped).void).void }
            def initialize(&block); end

            sig {
              params(request: Google::Cloud::RecaptchaEnterprise::V1::CreateAssessmentRequest)
              .returns(Google::Cloud::RecaptchaEnterprise::V1::Assessment)
            }
            def create_assessment(request); end
          end
        end

        class Assessment

          sig { returns(T.untyped()) }
          def token_properties; end
        end
      end
    end
  end
end
