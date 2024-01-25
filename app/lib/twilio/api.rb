# typed: strict

module Twilio
  class API
    extend T::Sig

    sig { returns(T.untyped) }
    attr_accessor :client

    sig { void }
    def initialize
      @client = Twilio::REST::Client.new Settings.twilio.api_key_sid, Settings.twilio.api_key_secret, Settings.twilio.account_sid
      @client.edge = 'tokyo'
      @tenant = T.let(T.must(Tenant.current), Tenant)
    end

    # SMS配信API
    # https://www.twilio.com/docs/verify/api/verification
    sig { params(to: String, custom_code: String).returns(T.untyped) }
    def send_sms_with_twilio_verify(to:, custom_code:) # rubocop:disable Naming/MethodParameterName
      @client.verify.v2
        .services(T.must(@tenant.tenant_setting).twilio_verify_service_sid)
        .verifications
        .create(
          to:,
          custom_code:,
          channel: 'sms',
        )
    end
  end
end
