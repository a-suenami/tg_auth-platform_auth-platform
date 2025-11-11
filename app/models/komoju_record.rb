# typed: strict
# frozen_string_literal: true

# KomojuRecord module for Komoju payment integration
class KomojuRecord
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    'komoju_record_'
  end
end
