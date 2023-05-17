Sentry.init do |config|
  # if Sidekiq.server?
  #   # Sidekiq の job では default で無視される例外設定を使用せずにそれらを捕捉する
  #   config.excluded_exceptions = []
  # end

  config.excluded_exceptions += [
    'Exceptions::Internal::ExpectedException',
  ]
end
