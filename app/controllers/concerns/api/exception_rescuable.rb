# ==============================================================================
# app - controllers - concerns - api - exception rescuable
# ==============================================================================
module API::ExceptionRescuable
  extend ActiveSupport::Concern

  included do
    include API::JSONErrorResponse

    rescue_from Exception, with: :handle_internal_server_error unless Rails.env.development? || Rails.env.test?

    rescue_from Exceptions::BaseError, with: :handle_bad_request_exception

    rescue_from ActiveRecord::RecordNotFound,       with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid,        with: :handle_record_invalid
    rescue_from ActiveRecord::RecordNotDestroyed,   with: :handle_record_not_destroyed
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pagy::OverflowError,                with: :pagy_overflow

    rescue_from ActiveRecord::RecordNotUnique, with: :handle_record_not_unique
    # rescue_from ActionView::MissingTemplate, with: :handle_missing_template

    rescue_from Exceptions::Auth::AuthError,             with: :handle_auth_error
    rescue_from Exceptions::API::BaseError,              with: :handle_api_error
    # rescue_from Exceptions::App::RecordInvalid, with: :handle_record_invalid_with_object
  end

  def handle_record_not_found
    resource_not_found(message: I18n.t('errors.messages.not_found'))
  end

  def handle_record_invalid(exception = nil)
    record = exception.record
    params = { messages: record.errors.as_json(full_messages: true), details: record.errors.details }

    invalid_request_error(
      code: :validation_error,
      message: I18n.t('errors.messages.error_occurred'),
      params:,
    )
  end

  def handle_record_not_unique(exception = nil)
    # unique エラーが起きすぎているため追跡のためSentryに送信する
    Sentry.set_user(id: current_user&.id) if try(:current_user)
    Sentry.capture_exception(exception)

    invalid_request_error(
      code: :record_not_unique_error,
      message: I18n.t('errors.messages.error_occurred'),
    )
  end

  # def handle_record_invalid_with_object(exception)
  #   record = exception.record
  #   params = { messages: record.errors.as_json(full_messages: true), details: record.errors.details }

  #   invalid_request_error(
  #     code: :validation_error,
  #     message: I18n.t('errors.messages.error_occurred'),
  #     params:,
  #     object: exception.object,
  #   )
  # end

  def handle_record_not_destroyed(exception = nil)
    record = exception.record
    params = { messages: record.errors.as_json(full_messages: true), details: record.errors.details }

    invalid_request_error(
      code: :deletion_error,
      message: I18n.t('errors.messages.error_occurred'),
      params:,
    )
  end

  def handle_bad_request_exception(exception = nil)
    invalid_request_error(
      code: exception.try(:code),
      message: exception.message,
      params: exception.try(:params),
    )
  end

  def handle_parameter_missing
    invalid_request_error(code: :invalid_parameter, message: I18n.t('errors.messages.parameter_missing'))
  end

  def pagy_overflow
    render json: { data: [], included: [] }
  end


  def handle_auth_error(exception)
    authentication_error(
      code: exception.try(:error_code).presence || :invalid_request,
      message: exception.message,
    )
  end

  def handle_api_error(exception)
    invalid_request_error(
      code: exception.try(:error_code).presence || :invalid_request,
      message: exception.message,
    )
  end

  def handle_internal_server_error(exception = nil)
    Sentry.set_user(id: current_user&.id) if try(:current_user)
    Sentry.capture_exception(exception)
    logger.error("Rendering 500 with exception: #{exception.message}") if exception
    logger.error(exception.backtrace.join('\n')) if exception

    internal_server_error(
      message: I18n.t('errors.messages.something_went_wrong'),
    )
  end
end
