# typed: strict

module AppShopifyMultipass
  class CreateAuthorizationEndpointUrlService < BaseService

    sig do
      params(
        shopify_record_multipass_store: ShopifyRecord::MultipassStore,
        oauth_authorization_path: String,
        redirect_uri: String,
        sign_up: T::Boolean,
      ).returns([String, String])
    end
    def execute(shopify_record_multipass_store:, oauth_authorization_path:, redirect_uri:, sign_up: false)
      code_verifier = generate_code_verifier
      code_challenge = generate_code_challenge(code_verifier)
      query_hash = {
        response_type: 'code',
        client_id: shopify_record_multipass_store.oauth_client_id,
        code_challenge:,
        code_challenge_method: 'S256',
        redirect_uri:,
        scope: shopify_record_multipass_store.scopes,
      }

      # 新規登録フローの場合はフラグを追加
      if sign_up
        query_hash[:on_no_session] = 'sign_up'
      end

      query = query_hash.to_query

      [code_verifier, "#{oauth_authorization_path}/?#{query}"]
    end


    private

    sig { returns(String) }
    def generate_code_verifier
      # TODO: [A-Z] / [a-z] / [0-9] / "-" / "." / "_" / "~" 最低43文字、最大128文字
      # とりあえずランダム
      SecureRandom.alphanumeric(43)
    end

    sig { params(code_verifier: String).returns(String) }
    def generate_code_challenge(code_verifier)
      Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(code_verifier), padding: false)
    end
  end
end
