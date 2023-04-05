# typed: strict

class OauthAccessGrant < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant
  include Multitenancy
end
