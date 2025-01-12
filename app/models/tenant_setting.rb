# typed: strict

class TenantSetting < ApplicationRecord
  extend T::Sig
  include Multitenancy

  validate :validate_json_format

  belongs_to :tenant


  private

  # JSONフォーマットの検証
  sig { void }
  def validate_json_format
    # nilの場合は検証しない
    return if self.profile_field_rules.nil? || self.profile_field_rules.empty?
    # JSONとしてパースできるかを確認
    JSON.parse(self.profile_field_rules)
  rescue JSON::ParserError
    errors.add(:profile_field_rules, 'must be a valid JSON object')
  end
end
