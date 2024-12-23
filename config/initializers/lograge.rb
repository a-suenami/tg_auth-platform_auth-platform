# ==============================================================================
# config - initializers - lograge
# ==============================================================================
# rubocop:disable Metrics/BlockLength
Rails.application.configure do
  next unless Rails.env.production?

  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new
  config.colorize_logging = false

  config.lograge.base_controller_class = ['ActionController::API', 'ActionController::Base']

  config.lograge.custom_payload do |controller|
    payload = {
      # Standard Attributes
      ddsource: 'ruby',
      network: {
        client: {
          ip: controller.request.remote_ip,
        },
      },
      http: {
        method: controller.request.method,
        url: controller.request.url,
        useragent: controller.request.user_agent,
        request_id: controller.request.request_id,
        referer: controller.request.referer,
        status_code: controller.response.status.to_s,

        # Custom
        x_forwarded_for: controller.request.headers[:HTTP_X_FORWARDED_FOR],
        x_app_version: controller.request.headers[:HTTP_X_APP_VERSION],
      },
      # Custom
      app: {
        current_tenant: RequestStore.store[:current_tenant]&.to_s,
      },
    }

    begin
      if controller.controller_path =~ %r{\Aapi/v1/(private|authentication|internal)}
        payload[:user_id] = controller.send(:current_user)&.id
      end
    rescue
      nil
    end

    begin
      if controller.response.status >= 400 && controller.response.media_type == 'application/json'
        payload[:http].merge!(
          response: {
            status: controller.response.status,
            body: JSON.parse(controller.response.body),
          },
        )
      end
    rescue => e
      Sentry.capture_exception(e)
    end

    payload
  end

  config.lograge.custom_options = lambda { |event|
    exceptions = %w[controller action format id]
    payload = {
      level: 'INFO',
      type: 'access',
      params: event.payload[:params].except(*exceptions),
      exception_object: event.payload[:exception_object],
      exception: event.payload[:exception],
      backtrace: event.payload[:exception_object].try(:backtrace),
    }

    # if Settings.datadog.enabled
    #   correlation = Datadog::Tracing.correlation
    #   payload[:dd] = {
    #     trace_id: correlation.trace_id.to_s,
    #     span_id: correlation.span_id.to_s,
    #     env: correlation.env.to_s,
    #     version: correlation.version.to_s,
    #   }
    # end

    payload
  }

  config.lograge.ignore_actions = [
    'ApplicationController#health_check',
  ]
end
# rubocop:enable Metrics/BlockLength
