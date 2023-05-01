# typed: false

module Blastengine
  class API
    attr_accessor :client

    def initialize
      @endpoint_url = 'https://app.engn.jp'
      @client = Faraday.new(@endpoint_url) do |f|
        f.response :json
        f.headers = {
          Authorization: "Bearer #{access_token}",
          'Content-Type': 'application/json',
          'Accept-Language': 'ja-JP',
        }
      end
    end

    def send_email(send_to:, subject:, body:)
      request(:post, '/api/v1/deliveries/transaction', {
        from: {
          email: 'sakata@twogate.com', # TODO: set sender email
        },
        to: send_to,
        subject:,
        text_part: ActionView::Base.full_sanitizer.sanitize(body, tags: []),
        html_part: body,
      },)
    end

    private

    def access_token
      hashed_token = Digest::SHA256.hexdigest(Settings.blastengine.user_id + Settings.blastengine.api_key)
      Base64.encode64(hashed_token.downcase).gsub("\n", '')
    end

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
