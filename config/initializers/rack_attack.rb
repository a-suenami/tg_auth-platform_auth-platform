RATELIMIT_PATHS = [
  '/api/v1/authentication/sessions',
  '/api/v1/authentication/registrations/verify_email',
  '/api/v1/authentication/password_resets',
].freeze

Rack::Attack.throttle('new session throttling', limit: 2, period: 2) do |request|
  if request.post? && RATELIMIT_PATHS.include?(request.path)
    request.ip
  end
end
