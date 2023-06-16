# ==============================================================================
# app - controllers - concerns - api - json error response
# ==============================================================================
module API::JSONErrorResponse
  def generate_json(message:, type: caller_locations.first.label.to_sym, code: nil, params: nil)
    error = {}
    error[:type] = type
    error[:code] = code unless code.nil?
    error[:message] = message
    error[:params] = params unless params.nil?

    error
  end

  # HTTP 400
  def invalid_request_error(code:, message:, params: nil, object: {})
    error = generate_json(code:, message:, params:)

    render json: { error: }.merge(object), status: :bad_request
  end

  # HTTP 401
  def authentication_error(code:, message:)
    error = generate_json(code:, message:)

    render json: { error: }, status: :unauthorized
  end

  # HTTP 403
  def forbidden(message:)
    error = generate_json(message:)

    render json: { error: }, status: :forbidden
  end

  # HTTP 404
  def resource_not_found(message:)
    error = generate_json(message:)

    render json: { error: }, status: :not_found
  end

  # HTTP 500
  def internal_server_error(message:, code: nil)
    error = generate_json(code:, message:)

    render json: { error: }, status: :internal_server_error
  end
end
