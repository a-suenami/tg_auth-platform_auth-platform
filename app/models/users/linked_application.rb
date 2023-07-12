# typed: strict

module Users
  class LinkedApplication < ApplicationRecord
    extend T::Sig
    include Multitenancy

    belongs_to :user
    belongs_to :oauth_application,
      class_name: 'OauthApplication',
      inverse_of: :linked_applications
  end
end
