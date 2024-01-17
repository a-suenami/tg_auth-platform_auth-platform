# typed: strict

module Blastengine
  class API
    extend T::Sig

    sig { returns(T.untyped) }
    attr_accessor :client

    sig { void }
    def initialize
      @endpoint_url = T.let('https://app.engn.jp', String)
      @client = T.let(Faraday.new(@endpoint_url) do |f|
        f.response :json
        f.headers = {
          Authorization: "Bearer #{access_token}",
          'Content-Type': 'application/json',
          'Accept-Language': 'ja-JP',
        }
      end, T.untyped,)
    end

    sig { params(send_to: String, subject: String, body: String, from_email: String, from_name: T.nilable(String)).returns(T.untyped) }
    def send_email(send_to:, subject:, body:, from_email:, from_name:)
      from_email = 'idp@id-platform.net' if from_email.blank?
      from_name = 'ID Platform' if from_name.blank?

      request(:post, '/api/v1/deliveries/transaction', {
        from: {
          email: from_email,
          name: from_name,
        },
        to: send_to,
        subject:,
        text_part: ActionView::Base.full_sanitizer.sanitize(body, tags: []),
        html_part: body,
      },)
    end

    private

    sig { returns(String) }
    def access_token
      hashed_token = Digest::SHA256.hexdigest(Settings.blastengine.user_id + Settings.blastengine.api_key)
      Base64.encode64(hashed_token.downcase).gsub("\n", '')
    end

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
