RATELIMIT_PATHS = [
  '/api/v1/authentication/sessions',
  '/api/v1/authentication/registrations/verify_email',
  '/api/v1/authentication/password_resets',
  '/api/v1/internal/email_change',
  '/oauth/token',
].freeze

RATELIMIT_PATHS.each do |path|
  Rack::Attack.throttle("limit #{path}", limit: 6, period: 60) do |request|
    if request.post? && request.path == path
      request.ip
    end
  end
end
