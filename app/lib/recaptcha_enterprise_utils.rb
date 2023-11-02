# typed: strict

# ==============================================================================
# app - lib - recaptcha_enterprise_utils
# ==============================================================================
require 'google/cloud/recaptcha_enterprise/v1'

class RecaptchaEnterpriseUtils
  extend T::Sig

  sig { params(tenant: Tenant, token: String, expected_action: String).void }
  def initialize(tenant:, token:, expected_action: 'checkout')
    @tenant = T.let(tenant, Tenant)
    @token = T.let(token, String)
    @expected_action = T.let(expected_action, String)
    @client = T.let(
      Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client.new do |config|
        config.credentials = JSON.parse(T.must(Settings.google_cloud_platform.recaptcha.google_cloud_service_account))
      end,
      Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client,
    )
  end

  sig { returns([T::Boolean, T.any(Symbol, Integer)]) }
  def validate
    assessment = create_assessment.token_properties

    validity = assessment.valid && assessment.action == @expected_action

    return validity, assessment.invalid_reason
  end

  private

  sig { returns(Google::Cloud::RecaptchaEnterprise::V1::Assessment) }
  def create_assessment
    request = Google::Cloud::RecaptchaEnterprise::V1::CreateAssessmentRequest.new(
      parent: "projects/#{T.must(Settings.google_cloud_platform.recaptcha.project_id)}",
      assessment: Google::Cloud::RecaptchaEnterprise::V1::Assessment.new(
        event: Google::Cloud::RecaptchaEnterprise::V1::Event.new(
          site_key: T.must(Settings.google_cloud_platform.recaptcha.key),
          token: @token,
          expected_action: @expected_action,
        ),
      ),
    )
    response = @client.create_assessment(request)

    response
  end
end
