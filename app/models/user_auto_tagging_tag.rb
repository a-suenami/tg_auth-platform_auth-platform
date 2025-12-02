# typed: strict

class UserAutoTaggingTag < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user_auto_tagging
  belongs_to :user_tag

  validates :user_tag_id, uniqueness: { scope: :user_auto_tagging_id }
end
