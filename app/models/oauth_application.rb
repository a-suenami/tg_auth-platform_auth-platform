# typed: strict

class OauthApplication < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Multitenancy

  validates :scopes, presence: true
end
