# typed: strict

class UserAutoTaggingTag < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :user_auto_tagging
  belongs_to :user_tag

  # Each tag can only be used in ONE auto-tagging rule per tenant
  validates :user_tag_id, uniqueness: { scope: :tenant_id, message: :already_used_in_another_rule }
end
