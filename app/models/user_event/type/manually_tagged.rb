# typed: strict
# frozen_string_literal: true

class UserEvent::Type::ManuallyTagged < UserEvent::Type::Base
  attribute :tag_id, :string
  attribute :tagged_by, :string

  validates :tag_id, presence: true
  validates :tagged_by, presence: true
end
