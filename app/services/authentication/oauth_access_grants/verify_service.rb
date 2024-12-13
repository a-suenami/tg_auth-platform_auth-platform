# typed: strict

module Authentication::OauthAccessGrants
  class VerifyService < Authentication::BaseService
    sig { params(token: String, oauth_client_id: String, code_verifier: String).returns(T.nilable(OauthAccessGrant)) }
    def execute!(token:, oauth_client_id:, code_verifier:)
      oauth_access_grant = OauthAccessGrant.find_by(token:)

      # oauth_access_grantが存在しない場合
      return nil if oauth_access_grant.blank?

      # oauth_access_grantがアクセス可能でない場合
      return nil unless oauth_access_grant.accessible?

      # code_verifierが一致しない場合
      return nil if oauth_access_grant.code_challenge != generate_code_challenge(code_verifier)

      # client_idが一致しない場合
      return nil if T.must(oauth_access_grant.application).uid != oauth_client_id

      # 一度使用したcodeは絶対失効させる!
      oauth_access_grant.revoke(Time.zone)
      oauth_access_grant
    end

    private

    sig { params(code_verifier: String).returns(String) }
    def generate_code_challenge(code_verifier)
      Base64.urlsafe_encode64(OpenSSL::Digest::SHA256.digest(code_verifier), padding: false)
    end
  end
end
