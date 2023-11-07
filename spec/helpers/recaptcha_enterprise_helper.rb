# ==============================================================================
# spec - helpers - recaptcha enterprise helper
# ==============================================================================
require 'google/cloud/recaptcha_enterprise/v1'
module RecaptchaEnterpriseHelper
  extend ActiveSupport::Concern
  included do
    let(:captcha_token) { 'captcha_token' }
    let(:captcha_validity) { true }
    let(:captcha_action) { 'checkout' }
    let(:captcha_invalid_reason) { :INVALID_REASON_UNSPECIFIED }
    # OPTIMIZE: Use verified doubles
    # rubocop:disable RSpec/VerifiedDoubles
    let(:recaptcha_double) { double(Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client) }
    let(:assessment_double) { double(Google::Cloud::RecaptchaEnterprise::V1::Assessment) }
    let(:token_properties_double) { double(Google::Cloud::RecaptchaEnterprise::V1::TokenProperties) }
    # rubocop:enable RSpec/VerifiedDoubles
    before do
      RSpec::Sorbet.allow_doubles!
      allow(Google::Cloud::RecaptchaEnterprise::V1::RecaptchaEnterpriseService::Client).to receive(:new).and_return(recaptcha_double)
      allow(recaptcha_double).to receive(:create_assessment).and_return(assessment_double)
      allow(assessment_double).to receive(:token_properties).and_return(token_properties_double)
      allow(token_properties_double).to receive(:valid).and_return(captcha_validity)
      allow(token_properties_double).to receive(:action).and_return(captcha_action)
      allow(token_properties_double).to receive(:invalid_reason).and_return(captcha_invalid_reason)
    end
  end
end
