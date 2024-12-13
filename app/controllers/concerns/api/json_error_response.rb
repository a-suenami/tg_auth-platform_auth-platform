# typed: strict

# ==============================================================================
# app - controllers - concerns - api - json error response
# ==============================================================================
module API::JSONErrorResponse
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionController::API }
  requires_ancestor { Kernel }

  sig { params(message: String, type: T.nilable(Symbol), code: T.nilable(Symbol), params: T.nilable(T::Hash[Symbol, T.untyped])).returns(T::Hash[Symbol, T.untyped]) }
  def generate_json(message:, type: caller_locations.first&.label&.to_sym, code: nil, params: nil)
    error = {}
    error[:type] = type
    error[:code] = code unless code.nil?
    error[:message] = message
    error[:params] = params unless params.nil?

    error
  end

  # HTTP 400
  sig { params(code: Symbol, message: String, params: T.nilable(T::Hash[Symbol, T.untyped]), object: T::Hash[Symbol, T.untyped]).void }
  def invalid_request_error(code:, message:, params: nil, object: {})
    error = generate_json(code:, message:, params:)

    render json: { error: }.merge(object), status: :bad_request
  end

  # HTTP 401
  sig { params(code: Symbol, message: String).void }
  def authentication_error(code:, message:)
    error = generate_json(code:, message:)

    render json: { error: }, status: :unauthorized
  end

  # HTTP 403
  sig { params(message: String).void }
  def forbidden(message:)
    error = generate_json(message:)

    render json: { error: }, status: :forbidden
  end

  # HTTP 404
  sig { params(message: String).void }
  def resource_not_found(message:)
    error = generate_json(message:)

    render json: { error: }, status: :not_found
  end

  # HTTP 500
  sig { params(message: String, code: T.nilable(Symbol)).void }
  def internal_server_error(message:, code: nil)
    error = generate_json(code:, message:)

    render json: { error: }, status: :internal_server_error
  end
end
