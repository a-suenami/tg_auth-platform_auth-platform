# typed: false
# frozen_string_literal: true

module FeatureFlaggable
  extend ActiveSupport::Concern

  included do
    helper_method :feature_enabled?
  end

  class_methods do
    # Declare required feature flag for entire controller
    def require_feature(flag_name, **options)
      before_action(**options) do
        require_feature!(flag_name)
      end
    end
  end

  private

  def feature_enabled?(flag_name)
    TenantFeatureFlags.enabled?(flag_name)
  end

  def require_feature!(flag_name)
    return if feature_enabled?(flag_name)

    respond_to do |format|
      format.html do
        flash[:alert] = 'この機能は現在利用できません'
        redirect_back fallback_location: admin_area_root_path
      end
      format.json do
        render json: { error: 'Feature not available' }, status: :forbidden
      end
    end
  end
end
