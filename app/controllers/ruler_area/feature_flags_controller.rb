# typed: false
# frozen_string_literal: true

module RulerArea
  class FeatureFlagsController < ApplicationController
    AVAILABLE_FEATURES = [:delivery].freeze

    def index
      @features = AVAILABLE_FEATURES
      @tenants = Tenant.all.order(:name)

      # Prepare feature status data for view
      @feature_status = @features.each_with_object({}) do |feature, hash|
        hash[feature] = {
          global_on: TenantFeatureFlags.globally_enabled?(feature),
          tenant_status: @tenants.each_with_object({}) do |tenant, tenant_hash|
            tenant_hash[tenant.id] = TenantFeatureFlags.enabled_for_tenant?(feature, tenant)
          end
        }
      end
    end

    # Toggle feature flag (tenant-specific or global)
    def toggle
      feature = params[:feature].to_sym
      enable = params[:enable] == 'true'

      unless AVAILABLE_FEATURES.include?(feature)
        redirect_to ruler_area_feature_flags_path, alert: '不正なフィーチャーが指定されました'
        return
      end

      if params[:global] == 'true'
        # Toggle global (boolean gate)
        if enable
          TenantFeatureFlags.enable_globally(feature)
          flash[:notice] = "#{feature} をグローバルで有効にしました"
        else
          TenantFeatureFlags.disable_globally(feature)
          flash[:notice] = "#{feature} をグローバルで無効にしました"
        end
      else
        # Toggle tenant-specific (actor gate)
        tenant = Tenant.find(params[:tenant_id])

        if enable
          TenantFeatureFlags.enable(feature, tenant)
          flash[:notice] = "#{feature} を #{tenant.name} で有効にしました"
        else
          TenantFeatureFlags.disable(feature, tenant)
          flash[:notice] = "#{feature} を #{tenant.name} で無効にしました"
        end
      end

      redirect_to ruler_area_feature_flags_path
    end
  end
end
