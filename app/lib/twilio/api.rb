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
    end

    # SMS配信API
    sig { params(send_to: String, body: String).returns(T.untyped) }
    def send_sms(send_to:, body:)
      @client.messages
        .create(
          body:,
          from: Settings.twilio.sender_number,
          to: send_to,
        )
    end
  end
end
