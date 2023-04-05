# typed: strict

class OauthAccessToken < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessToken
  include Multitenancy
end
