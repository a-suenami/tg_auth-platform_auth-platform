# typed: strict
# frozen_string_literal: true

module AdminArea::ExceptionRescuable
  extend T::Sig
  extend T::Helpers
  extend ActiveSupport::Concern

  requires_ancestor { ActionController::Base }

  included do
    T.bind(self, ActiveSupport::Rescuable::ClassMethods)

    rescue_from ActiveRecord::RecordInvalid, with: :handle_validation_error
    rescue_from ActiveRecord::RecordNotFound, with: :handle_not_found
  end

  private

  sig { params(exception: ActiveRecord::RecordInvalid).void }
  def handle_validation_error(exception)
    redirect_back fallback_location: admin_area_root_path,
                  alert: I18n.t('errors.messages.error_occurred', message: exception.message)
  end

  sig { params(exception: ActiveRecord::RecordNotFound).void }
  def handle_not_found(_exception)
    redirect_to admin_area_root_path,
                alert: I18n.t('errors.messages.not_found')
  end
end
