# typed: strict

# ==============================================================================
# app/models/tenant/design_setting.rb
# ==============================================================================
class Tenant::DesignSetting < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant

  # 画像は URL 文字列として保存（Active Storage 未使用のため）
  # membership_card_image_url, login_side_image_url, logo_image_url

  validates :tenant_id, uniqueness: true
  validates :color_primary, :color_primary_light, :color_accent, :color_accent_light, presence: true

  validate :footer_links_limit
  validate :footer_sub_links_limit

  # デフォルト値付きアクセサ
  sig { returns(String) }
  def font_family_heading
    super.presence || "'Zen Maru Gothic', sans-serif"
  end

  sig { returns(String) }
  def font_family_base
    super.presence || "'Hiragino Sans', sans-serif"
  end

  sig { returns(T::Array[T::Hash[String, String]]) }
  def footer_links
    super || []
  end

  sig { returns(T::Array[T::Hash[String, String]]) }
  def footer_sub_links
    super || []
  end

  private

  sig { void }
  def footer_links_limit
    errors.add(:footer_links, 'は最大10件までです') if footer_links.is_a?(Array) && footer_links.size > 10
  end

  sig { void }
  def footer_sub_links_limit
    errors.add(:footer_sub_links, 'は最大10件までです') if footer_sub_links.is_a?(Array) && footer_sub_links.size > 10
  end
end
