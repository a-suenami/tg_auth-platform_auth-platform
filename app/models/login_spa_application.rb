# typed: strict

class LoginSpaApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  sig { returns(String) }
  def login_url_with_flag
    return '' if login_url.blank?

    uri = URI.parse(T.must(login_url))
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end

  sig { returns(String) }
  def sign_up_url_with_flag
    return '' if login_url.blank?

    attach_oauth_flow_flag(sign_up_url)
  end

  private

  sig { params(url: T.nilable(String)).returns(String) }
  def attach_oauth_flow_flag(url)
    uri = URI.parse(T.must(url))
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end
end
