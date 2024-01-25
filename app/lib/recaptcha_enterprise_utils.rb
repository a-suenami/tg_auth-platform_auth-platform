# typed: strict

# ==============================================================================
# app - lib - recaptcha_enterprise_utils
# ==============================================================================
require 'google/cloud/recaptcha_enterprise/v1'

class RecaptchaEnterpriseUtils
  extend T::Sig

  class Integration < T::Enum
    enums do
      ScoreBased = new('score_based')
      Checkbox   = new('checkbox')
    end
  end

  class Action < T::Enum
    enums do
      Signup = new('signup')
    end
  end

  class Errors
    class BaseError < StandardError
      extend T::Sig
      extend T::Helpers

      abstract!

      sig { abstract.returns(Symbol) }
      def code; end

      sig { abstract.returns(String) }
      def message; end
    end

    class InvalidToken < BaseError
      extend T::Sig

      sig { override.returns(String) }
      def message
        'The captcha token is invalid.'
      end

      sig { override.returns(Symbol) }
      def code
        :invalid_captcha_token
      end
    end

    class ScoreTooLow < BaseError
      extend T::Sig

      sig { override.returns(String) }
      def message
        'The captcha score is too low.'
      end

      sig { override.returns(Symbol) }
      def code
        :captcha_score_too_low
      end
    end
  end

  class Assessment
    extend T::Sig

    sig { returns(T::Boolean) }
    attr_reader :valid

    sig { returns(Float) }
    attr_reader :score

    sig { returns(T.nilable(Errors::BaseError)) }
    attr_reader :error

    sig { params(valid: T::Boolean, score: Float, error: T.nilable(Errors::BaseError)).void }
    def initialize(valid:, score:, error:)
      @valid = valid
      @score = score
      @error = error
    end
  end

  sig { returns(Tenant) }
  attr_reader :tenant

  sig { returns(String) }
  attr_reader :token

  sig { returns(Integration) }
  attr_reader :integration

  sig { returns(Action) }
  attr_reader :expected_action

  sig { returns(Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client) }
  attr_reader :client

  sig { returns(T.nilable(String)) }
  attr_reader :site_key

  MINIMUM_ACCEPTABLE_SCORE = T.let(0.5, Float)

  sig { params(tenant: Tenant, token: String, integration: Integration, expected_action: Action).void }
  def initialize(tenant:, token:, integration: Integration::Checkbox, expected_action: Action::Signup)
    @tenant = T.let(tenant, Tenant)
    @token = T.let(token, String)
    @integration = T.let(integration, Integration)
    @expected_action = T.let(expected_action, Action)
    @client = T.let(
      Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client.new do |config|
        config.credentials = JSON.parse(T.must(T.must(@tenant.tenant_setting).google_cloud_service_account))
      end,
      Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client,
    )
    @site_key = T.let(
      case @integration
      when Integration::ScoreBased
        T.must(@tenant.tenant_setting).recaptcha_enterprise_score_based_site_key
      when Integration::Checkbox
        T.must(@tenant.tenant_setting).recaptcha_enterprise_checkbox_site_key
      else
        T.absurd(@integration)
      end,
      T.nilable(String),
    )
  end

  sig { returns(Assessment) }
  def assess
    assessment = create_assessment
    error = nil

    case @integration
    when Integration::ScoreBased
      if assessment.token_properties&.valid && assessment.token_properties&.action == expected_action.serialize
        if assessment.risk_analysis&.score.to_f >= MINIMUM_ACCEPTABLE_SCORE
          valid = true
        else
          valid = false
          error = Errors::ScoreTooLow.new
        end
      else
        valid = false
        error = Errors::InvalidToken.new
      end
    when Integration::Checkbox
      if assessment.token_properties&.valid && assessment.token_properties&.action == expected_action.serialize
        valid = true
      else
        valid = false
        error = Errors::InvalidToken.new
      end
    else
      T.absurd(@integration)
    end

    score = assessment.risk_analysis&.score.to_f
    assessment = Assessment.new(valid:, score:, error:)

    assessment
  end

  private

  sig { returns(Google::Cloud::RecaptchaEnterprise::V1::Assessment) }
  def create_assessment
    request = Google::Cloud::RecaptchaEnterprise::V1::CreateAssessmentRequest.new(
      parent: "projects/#{T.must(T.must(tenant.tenant_setting).google_cloud_project_id)}",
      assessment: Google::Cloud::RecaptchaEnterprise::V1::Assessment.new(
        event: Google::Cloud::RecaptchaEnterprise::V1::Event.new(
          site_key:,
          token:,
          expected_action: expected_action.serialize,
        ),
      ),
    )
    response = client.create_assessment(request)

    response
  end
end
