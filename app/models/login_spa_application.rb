# typed: strict

class LoginSpaApplication < ApplicationRecord
  extend T::Sig
  include Multitenancy

  sig { params(return_to: T.untyped).returns(T::Boolean) }
  def vaild_return_to?(return_to)
    (allowed_logout_urls.split(',') & [return_to]).count.positive?
  end
end
