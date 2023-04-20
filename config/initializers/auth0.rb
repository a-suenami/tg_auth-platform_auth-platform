Rails.application.config.middleware.use OmniAuth::Builder do
  provider(
    :auth0,
    Settings.admin.auth0.auth0_client_id,
    Settings.admin.auth0.auth0_client_secret,
    Settings.admin.auth0.auth0_domain,
    path_prefix: '/admin/auth',
    callback_path: '/admin/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile',
    },
  )
end
