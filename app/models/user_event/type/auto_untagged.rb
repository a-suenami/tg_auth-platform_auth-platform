# typed: strict
# frozen_string_literal: true

class UserEvent::Type::AutoUntagged < UserEvent::Type::Base
  attribute :tag_id, :string
  attribute :auto_tagging_rule_id, :string

  validates :tag_id, presence: true
  validates :auto_tagging_rule_id, presence: true
end
