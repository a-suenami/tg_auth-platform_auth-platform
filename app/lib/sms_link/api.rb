# typed: strict

module SmsLink
  class API
    extend T::Sig

    sig { returns(T.untyped) }
    attr_accessor :client

    sig { void }
    def initialize
      @endpoint_url = T.let('https://sand-api-smslink.nexlink2.jp', String)
      @client = T.let(Faraday.new(@endpoint_url) do |f|
        f.response :json
        f.headers = {
          token: Settings.sms_link.api_token,
          'Content-Type': 'application/json',
          Accept: 'application/json',
        }
      end, T.untyped,)
    end

    # SMS配信API
    sig { params(send_to: String, body: String).returns(T::Hash[T.untyped, T.untyped]) }
    def send_sms(send_to:, body:)
      request(:post, '/api/v1/delivery', {
        contacts: [
          {
            phone_number: send_to,
          },
        ],
        text_message: body,
      },)
    end

    # SMS配信結果取得API
    sig { params(delivery_id: String).returns(T::Hash[T.untyped, T.untyped]) }
    def fetch_sms_detail(delivery_id:)
      request(:get, "/api/v1/delivery_id/#{delivery_id}")
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
