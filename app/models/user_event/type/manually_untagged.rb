# typed: strict
# frozen_string_literal: true

class UserEvent::Type::ManuallyUntagged < UserEvent::Type::Base
  attribute :tag_id, :string
  attribute :untagged_by, :string

  validates :tag_id, presence: true
  validates :untagged_by, presence: true
end
