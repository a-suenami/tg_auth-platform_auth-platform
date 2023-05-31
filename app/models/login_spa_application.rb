# typed: strict

class LoginSpaApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  sig { params(return_to: T.untyped).returns(T::Boolean) }
  def vaild_return_to?(return_to)
    (allowed_logout_urls.split(',') & [return_to]).count.positive?
  end

  sig { returns(String) }
  def login_url_with_flag
    return '' if login_url.blank?

    uri = URI.parse(T.must(login_url))
    query = URI.decode_www_form(uri.query || '') << ['in_oauth_flow', 'true']
    uri.query = URI.encode_www_form(query)
    uri.to_s
  end
end
