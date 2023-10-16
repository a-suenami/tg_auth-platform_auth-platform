# typed: strict

class OauthApplication < ApplicationRecord
  extend T::Sig
  include ::Doorkeeper::Orm::ActiveRecord::Mixins::Application
  include Multitenancy

  validates :scopes, presence: true

  has_many :linked_applications,
    class_name: 'Users::LinkedApplication',
    inverse_of: :oauth_application
  has_many :users,
    through: :linked_applications,
    inverse_of: :oauth_applications
end
