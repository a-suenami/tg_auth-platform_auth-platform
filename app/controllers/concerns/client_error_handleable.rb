module ClientErrorHandleable
  extend ActiveSupport::Concern

  def handle_400(code: :bad_request, error_details: [], link: nil)
    handle_error(
      title: 'Bad Request',
      code:,
      status: 400,
      error_details:,
      link:,
    )
  end

  def handle_401(code: :unauthorized, error_details: [], link: nil)
    handle_error(
      title: 'Unauthorized',
      code:,
      status: 401,
      error_details:,
      link:,
    )
  end

  def handle_403(code: :forbidden, error_details: [], link: nil)
    handle_error(
      title: 'Forbidden',
      code:,
      status: 403,
      error_details:,
      link:,
    )
  end

  def handle_404(code: :not_found, error_details: [], link: nil)
    handle_error(
      title: 'Not Found',
      code:,
      status: 404,
      error_details:,
      link:,
    )
  end

  def handle_429(code: :too_many_request, error_details: [], link: nil)
    handle_error(
      title: 'Too Many Requests',
      code:,
      status: 429,
      error_details:,
      link:,
    )
  end

  private

  def handle_error(title: '', code: nil, status: 0, error_details: [], link: nil)
    errors = error_details.map do |error_detail|
      {
        code:,
        status:,
        title:,
        detail: error_detail,
        links: link,
      }
    end

    render json: { errors: errors.flatten }, status:
  end
end
