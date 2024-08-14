# typed: strict

class OauthAccessGrant < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::AccessGrant
  include Multitenancy

  belongs_to :resource_owner, class_name: 'User', optional: true
end
