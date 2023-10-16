# typed: strict

class LoginSpaApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  validates :login_url, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/
  validates :sign_up_url, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/, allow_blank: true
  validates :redirect_url_on_password_reset, format: /\A#{URI::DEFAULT_PARSER.make_regexp(%w[http https])}\z/

  sig { returns(String) }
  def login_url_with_flag
    attach_oauth_flow_flag(login_url)
  end

  sig { returns(String) }
  def sign_up_url_with_flag
    attach_oauth_flow_flag(sign_up_url)
  end

  private

  sig { params(url: T.nilable(String)).returns(String) }
  def attach_oauth_flow_flag(url)
    return '' if url.blank?

    uri = URI.parse(url)
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end
end
