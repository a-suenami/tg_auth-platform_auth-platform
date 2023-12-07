# ==============================================================================
# config - initializers - cors
# ==============================================================================
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow_origins = [
    %r{^(http|https)://localhost$},
    %r{^(http|https)://localhost:\d{4,5}$},
    %r{^(http|https)://127.0.0.1:\d{4,5}$},
    %r{^(ionic|capacitor)://localhost$},
    %r{^https://.+\.auth\.app-staging\.id-platform\.net$},
    %r{^https://.+\.auth\.app\.id-platform\.net$},
  ].map(&:freeze).freeze

  allow do
    # rubocop:disable Security/Eval
    origins allow_origins + eval(ENV['ALLOW_ORIGINS'] || '[]')
    # rubocop:enable Security/Eval

    resource '/*',
      headers: :any,
      expose: ['Total', 'Per-Page'],
      credentials: true,
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
end
