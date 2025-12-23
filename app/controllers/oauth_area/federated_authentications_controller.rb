module OauthArea
  class FederatedAuthenticationsController < ApplicationMetalController
    before_action :set_tenant
    before_action :require_feature!

    def redirect
      provider = Tenant.current.oauth_providers.find_by(provider: params[:provider])
      return render json: { error: 'Provider not found' }, status: :not_found unless provider

      redirect_to oauth_authorize_url(provider), allow_other_host: true
    end

    def callback
      provider = Tenant.current.oauth_providers.find_by(provider: params[:provider])
      return render json: { error: 'Provider not found' }, status: :not_found unless provider

      token_response = exchange_code_for_token(provider, params[:code])
      return render json: { error: 'Invalid token' }, status: :unauthorized unless token_response

      user_info = fetch_user_info(provider, token_response['access_token'], token_response['id_token'])
      return render json: { error: 'User info not found' }, status: :unauthorized unless user_info

      user = find_or_create_user(user_info)

      session[:user_id] = user.id
      render json: { success: true, user: user }
    end

    private

    def require_feature!
      return if TenantFeatureFlags.enabled?(:external_oauth_provider)

      render json: { error: 'Feature not available' }, status: :forbidden
    end

    def oauth_authorize_url(provider)
      "#{provider.auth_url}?client_id=#{provider.client_id}&redirect_uri=#{callback_url(provider)}&response_type=code&scope=#{provider.scopes}"
    end

    def callback_url(provider)
      "#{request.protocol}#{request.host_with_port}/federated_authentications/oauth/callback?provider=#{provider.provider}"
    end

    def exchange_code_for_token(provider, code)
      response = Faraday.post(provider.token_url, {
        client_id: provider.client_id,
        client_secret: provider.client_secret,
        code: code,
        grant_type: 'authorization_code',
        redirect_uri: callback_url(provider),
      },)

      JSON.parse(response.body) if response.success?
    end

    def fetch_user_info(provider, access_token, id_token)
      return decode_jwt(id_token) if id_token.present?

      return unless provider.user_info_url

      response = Faraday.get(provider.user_info_url) do |req|
        req.headers['Authorization'] = "Bearer #{access_token}"
      end

      JSON.parse(response.body) if response.success?
    end

    def decode_jwt(token)
      JWT.decode(token, nil, false).first
    rescue
      nil
    end

    def find_or_create_user(user_info)
      User.find_or_create_by(email: user_info['email']) do |user|
        # TODO: save external user
        # user.name = user_info['name'] || user_info['sub']
        # user.provider_uid = user_info['sub']
      end
    end
  end
end
