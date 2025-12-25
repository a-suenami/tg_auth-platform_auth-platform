# typed: strict

class OauthApplication < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Multitenancy

  # アプリケーションタイプ
  # - spa: シングルページアプリケーション（React, Vue 等）- 外部 login_url を使用
  # - traditional_web: 一般的な Web アプリケーション（Rails, Express 等）- 内部 /user_area/logins を使用
  # - native: ネイティブアプリ（iOS, Android 等）- 将来実装予定
  # - m2m: マシンツーマシン（バックエンドサービス）- 将来実装予定
  class ApplicationTypeEnum < T::Enum
    enums do
      Spa = new('spa')
      TraditionalWeb = new('traditional_web')
      Native = new('native')
      M2m = new('m2m')
    end
  end

  enumerize :application_type, enum_class: ApplicationTypeEnum, default: ApplicationTypeEnum::Spa.serialize

  validates :scopes, presence: true
  validates :login_url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true
  validates :sign_up_url, format: { with: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/ }, allow_blank: true

  has_many :linked_applications,
    class_name: 'Users::LinkedApplication',
    inverse_of: :oauth_application
  has_many :users,
    through: :linked_applications,
    inverse_of: :oauth_applications

  # 外部ログイン URL を使用するタイプかどうか
  sig { returns(T::Boolean) }
  def requires_external_login?
    application_type.in?(%w[spa native])
  end

  # 内部ログイン画面を使用するタイプかどうか
  sig { returns(T::Boolean) }
  def uses_internal_login?
    application_type == 'traditional_web'
  end

  # OAuth フローで使用するログイン URL を取得
  # SPA/Native の場合は外部 URL、Traditional Web の場合は nil（内部画面を使用）
  sig { params(require_sms_mfa: T::Boolean).returns(T.nilable(String)) }
  def effective_login_url(require_sms_mfa: false)
    return nil unless requires_external_login?
    return nil if login_url.blank?

    attach_oauth_flow_flag(login_url, require_sms_mfa:)
  end

  # OAuth フローで使用するサインアップ URL を取得
  sig { params(require_sms_mfa: T::Boolean).returns(T.nilable(String)) }
  def effective_sign_up_url(require_sms_mfa: false)
    return nil unless requires_external_login?
    return nil if sign_up_url.blank?

    attach_oauth_flow_flag(sign_up_url, require_sms_mfa:)
  end

  private

  sig { params(url: String, require_sms_mfa: T::Boolean).returns(String) }
  def attach_oauth_flow_flag(url, require_sms_mfa: false)
    uri = URI.parse(url)
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    query << ['require_sms_mfa', 'true'] if require_sms_mfa
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end
end
