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
  provider(
    :auth0_ruler,
    Settings.ruler.auth0.auth0_client_id,
    Settings.ruler.auth0.auth0_client_secret,
    Settings.ruler.auth0.auth0_domain,
    path_prefix: '/ruler/auth',
    callback_path: '/ruler/auth/auth0/callback',
    authorize_params: {
      scope: 'openid profile',
    },
  )
end
