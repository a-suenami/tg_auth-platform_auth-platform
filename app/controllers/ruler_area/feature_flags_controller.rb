# typed: false
# frozen_string_literal: true

module RulerArea
  class FeatureFlagsController < ApplicationController
    def index
      @features = FeatureFlagRegistry.all_flags
      @feature_status = @features.each_with_object({}) do |feature, hash|
        hash[feature] = {
          description: FeatureFlagRegistry.description(feature),
          global_on: TenantFeatureFlags.globally_enabled?(feature),
        }
      end
    end

    def toggle
      feature = params[:feature].to_sym
      enable = params[:enable] == 'true'

      unless FeatureFlagRegistry.valid?(feature)
        redirect_to ruler_area_feature_flags_path, alert: '不正なフィーチャーが指定されました'
        return
      end

      if enable
        TenantFeatureFlags.enable_globally(feature)
        flash[:notice] = "#{feature} をグローバルで有効にしました"
      else
        TenantFeatureFlags.disable_globally(feature)
        flash[:notice] = "#{feature} をグローバルで無効にしました"
      end

      redirect_to ruler_area_feature_flags_path
    end
  end
end
