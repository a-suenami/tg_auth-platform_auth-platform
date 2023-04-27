module ExceptionRescuable
  extend ActiveSupport::Concern

  included do
    include ClientErrorHandleable

    rescue_from Exception, with: :handle_500 if Rails.env.production?

    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :handle_record_invalid
    rescue_from AbstractController::ActionNotFound, with: :handle_action_not_found
    rescue_from ActionView::MissingTemplate, with: :handle_missing_template
    rescue_from ActionController::ParameterMissing, with: :handle_parameter_missing
    rescue_from Pagy::OverflowError, with: :pagy_overflow
  end

  def handle_record_not_found
    handle_404(error_details: ['対象のレコードが見つかりません'])
  end

  def handle_record_invalid(exception = nil)
    record = exception.record

    serialized_errors = record.errors.messages.map do |field, errors|
      errors.map do |error_message|
        {
          status: 400,
          source: { pointer: "/data/attributes/#{field}" },
          detail: error_message,
        }
      end
    end

    render json: { errors: serialized_errors.flatten }, status: :bad_request
  end

  def handle_action_not_found
    handle_404(error_details: ['対象のアクションが見つかりません'])
  end

  def handle_missing_template
    handle_404(error_details: ['テンプレートが見つかりません'])
  end

  def handle_parameter_missing
    handle_400(error_details: ['パラメーターが不足しています'])
  end

  def handle_bad_request_exception(exception = nil)
    handle_400(error_details: [exception.message])
  end

  def handle_access_denied
    handle_403(error_details: ['権限がありません'])
  end

  def pagy_overflow
    render json: { data: [], included: [] }
  end

  def handle_500(exception = nil)
    # Raven.user_context(user_id: current_user&.id) if try(:current_user)
    # Raven.capture_exception(exception)
    logger.error("Rendering 500 with exception: #{exception.message}") if exception
    logger.error(exception.backtrace.join("\n")) if exception

    render json: {
      errors: [
        {
          status: 500,
          title: 'Exception',
          detail: 'Internal server error.',
        },
      ],
    }, status: :internal_server_error
  end
end
