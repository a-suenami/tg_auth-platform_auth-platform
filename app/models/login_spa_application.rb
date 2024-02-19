# typed: strict

class LoginSpaApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  validates :login_url, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/
  validates :sign_up_url, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, allow_blank: true
  validates :redirect_url_on_password_reset, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

  sig { params(require_sms_mfa: T::Boolean).returns(String) }
  def login_url_with_flag(require_sms_mfa: false)
    attach_oauth_flow_flag(login_url, require_sms_mfa:)
  end

  sig { params(require_sms_mfa: T::Boolean).returns(String) }
  def sign_up_url_with_flag(require_sms_mfa: false)
    attach_oauth_flow_flag(sign_up_url, require_sms_mfa:)
  end

  private

  sig { params(url: T.nilable(String), require_sms_mfa: T::Boolean).returns(String) }
  def attach_oauth_flow_flag(url, require_sms_mfa: false)
    return '' if url.blank?

    uri = URI.parse(url)
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    query << ['require_sms_mfa', 'true'] if require_sms_mfa
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end
end
