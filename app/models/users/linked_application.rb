# typed: strict

module Users
  class LinkedApplication < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user
    belongs_to :oauth_applications,
      class_name: 'OauthApplication',
      foreign_key: :oauth_application_id,
      inverse_of: :linked_applications
  end
end
