# typed: strict

module SmsLink
  class API
    extend T::Sig

    DELIVERY_TYPE_CODE = T.let({
      sms: 10,
      voice: 20,
      sms_voice: 30,
      voice_sms: 40,
    }.freeze, T::Hash[Symbol, Integer],)

    RETRY_OPTIONS = T.let({
      max: 3,
      interval: 0.05,
      interval_randomness: 0.5,
      backoff_factor: 2,
      exceptions: Faraday::Retry::Middleware::DEFAULT_EXCEPTIONS + [Faraday::ConnectionFailed],
    }.freeze, T::Hash[T.untyped, T.untyped],)

    sig { returns(T.untyped) }
    attr_accessor :client

    sig { void }
    def initialize
      @endpoint_url = T.let('https://ss.smslink.jp', String)
      @client = T.let(Faraday.new(@endpoint_url) do |f|
        f.request :retry, RETRY_OPTIONS
        f.response :json
        f.headers = {
          Authorization: "Bearer #{Settings.sms_link.api_token}",
          'Content-Type': 'application/json',
        }
      end, T.untyped,)
    end

    # SMS配信API
    sig { params(sms_verifier: Users::SmsVerifier, delivery_type: T.nilable(String)).returns(T::Hash[T.untyped, T.untyped]) }
    def send_sms(sms_verifier:, delivery_type: 'sms')
      # 開発環境ではSMS送信を行わない
      return { verification_code_id: 'dummy_id' } unless Rails.env.production?

      delivery_type = :sms if delivery_type.nil?
      delivery_type_code = DELIVERY_TYPE_CODE[delivery_type.to_sym]

      request(:post, '/api/v1/verification_code/delivery', {
        phone_number: sms_verifier.japan_local_phone_number,
        delivery_type: delivery_type_code,
        sms_message: "[#{Tenant.current&.name}]\nコード:{{verification_code}}\n有効期限は10分です。他人には教えないでください。",
        voice_message: 'これからお伝えするコードを認証画面に入力してください。認証コードは{{verification_code}}です。繰り返します{{verification_code}}',
        verification_code: sms_verifier.code,
        user_reference: Tenant.current&.id,
      },)
    end

    # SMS配信結果取得API
    sig { params(verification_code_id: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_sms_detail(verification_code_id:)
      request(:get, '/api/v1/verification_code/delivery', {
        verification_code_id:,
      },)
    end

    private

    sig { params(http_method: Symbol, path: String, params: T.untyped, headers: T.untyped).returns(T.untyped) }
    def request(http_method, path, params = nil, headers = {})
      raise unless http_method.to_sym.in? [:get, :post, :put, :delete]

      response = case http_method
      when :get, :delete
        @client.send(http_method, path, params, headers)
      when :post, :put
        @client.send(http_method, path, params.to_json, headers)
      end

      body = response.body

      if response.status.to_s !~ /2\d\d/
        raise Exceptions::API::ServerError.new(body:, status: response.status)
      end

      body
    end
  end
end
