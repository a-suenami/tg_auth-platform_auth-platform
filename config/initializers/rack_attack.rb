RATELIMIT_PATHS = [
  '/api/v1/authentication/sessions',
  '/api/v1/authentication/registrations/send_verification_email',
  '/api/v1/authentication/registrations/verify_email',
  '/api/v1/authentication/sms_verify/send_verification_sms',
  '/api/v1/authentication/sms_verify/verify_sms',
  '/api/v1/authentication/password_resets',
  '/api/v1/internal/email_change',
  '/oauth/token',
].freeze

# 開発環境でrake_attackをテストするにはtmp/caching-dev.txtを作成してキャッシュを有効化させる必要がある

RATELIMIT_PATHS.each do |path|
  return if !Rails.env.production? && Settings.super_mode == true # SUPER_MODE では無効化

  Rack::Attack.throttle("limit #{path}", limit: 6, period: 60) do |request|
    if request.post? && request.path == path
      request.ip
    end
  end
end

Rack::Attack.throttled_responder = lambda do |_request|
  # NB: you have access to the name and other data about the matched throttle
  # request.env['rack.attack.matched']
  # request.env['rack.attack.match_type']
  # request.env['rack.attack.match_data']
  # request.env['rack.attack.match_discriminator']

  # Using 503 because it may make attacker think that they have successfully
  # DOSed the site. Rack::Attack returns 429 for throttling by default
  [
    429,
    { 'Content-Type': 'application/json; charset=utf-8' },
    [
      {
        error: {
          type: 'too_many_requests',
          code: 'too_many_requests',
          message: 'Retry later',
        },
      }.to_json,
    ],
  ]
end
