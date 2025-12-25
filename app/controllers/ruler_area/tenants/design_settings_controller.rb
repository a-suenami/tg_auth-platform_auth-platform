module RulerArea::Tenants
  class DesignSettingsController < ApplicationController
    def edit
      @design_setting = Tenant.current.design_setting || Tenant.current.build_design_setting
    end

    def update
      @design_setting = Tenant.current.design_setting || Tenant.current.build_design_setting
      @design_setting.assign_attributes(design_setting_params)

      # 画像ファイルをS3にアップロード
      upload_images

      if @design_setting.save
        redirect_to edit_ruler_area_tenant_design_settings_path(@tenant_id), notice: t('helpers.messages.updated')
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def design_setting_params
      params.require(:tenant_design_setting).permit(
        :color_primary,
        :color_primary_light,
        :color_accent,
        :color_accent_light,
        :font_family_heading,
        :font_family_base,
        :service_name,
        :description_text,
        footer_links: [:text, :url],
        footer_sub_links: [:text, :url],
      )
    end

    def upload_images
      uploader = S3::Uploader.new
      tenant_id = Tenant.current!.id

      %i[logo_image login_side_image membership_card_image].each do |image_key|
        file = params.dig(:tenant_design_setting, image_key)
        next unless file.is_a?(ActionDispatch::Http::UploadedFile)

        # 古い画像を削除
        old_url = @design_setting.send("#{image_key}_url")
        if old_url.present?
          old_path = uploader.extract_path_from_url(old_url)
          uploader.delete(path: old_path) if old_path.present?
        end

        # 新しい画像をアップロード
        extension = File.extname(file.original_filename)
        path = "tenants/#{tenant_id}/design_settings/#{image_key}_#{SecureRandom.uuid}#{extension}"
        url = uploader.upload(file: file, path: path)
        @design_setting.send("#{image_key}_url=", url)
      end
    end
  end
end
