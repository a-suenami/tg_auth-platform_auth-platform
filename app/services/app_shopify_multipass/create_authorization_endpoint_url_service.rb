# typed: true

module AppShopifyMultipass
  class CreateAuthorizationEndpointUrlService < BaseService

    def execute(shopify_record_multipass_setting:, oauth_authorization_path:, redirect_uri:)
      code_verifier = generate_code_verifier
      code_challenge = generate_code_challenge(code_verifier)
      query = {
        response_type: 'code',
        client_id: shopify_record_multipass_setting.oauth_client_id,
        code_challenge:,
        code_challenge_method: 'S256',
        redirect_uri:,
        scope: shopify_record_multipass_setting.scopes,
      }.to_query

      [code_verifier, "#{oauth_authorization_path}/?#{query}"]
    end


    private

    def generate_code_verifier
      # TODO: [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~" 最低43文字、最大128文字
      # とりあえずランダム
      SecureRandom.alphanumeric(43)
    end

    def generate_code_challenge(code_verifier)
      Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(code_verifier), padding: false)
    end
  end
end
