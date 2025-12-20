# typed: false
# frozen_string_literal: true

module RulerArea
  module Tenants
    class FeatureFlagsController < ApplicationController
      def index
        @features = FeatureFlagRegistry.tenant_flags
        @feature_status = @features.index_with do |feature|
          {
            description: FeatureFlagRegistry.description(feature),
            enabled: TenantFeatureFlags.enabled_for_tenant?(feature, @tenant),
            global_on: TenantFeatureFlags.globally_enabled?(feature),
          }
        end
      end

      def toggle
        feature = params[:feature].to_sym
        enable = params[:enable] == 'true'

        unless FeatureFlagRegistry.tenant_flag?(feature)
          redirect_to ruler_area_tenant_feature_flags_path(@tenant), alert: '不正なフィーチャーが指定されました'
          return
        end

        if enable
          TenantFeatureFlags.enable(feature, @tenant)
          flash[:notice] = "#{feature} を有効にしました"
        else
          TenantFeatureFlags.disable(feature, @tenant)
          flash[:notice] = "#{feature} を無効にしました"
        end

        redirect_to ruler_area_tenant_feature_flags_path(@tenant)
      end
    end
  end
end
