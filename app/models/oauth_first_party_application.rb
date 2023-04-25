# typed: strict

class OauthFirstPartyApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  def vaild_return_to?(return_to)
    (allowed_logout_urls.split(',') & [return_to]).count.positive?
  end
end
