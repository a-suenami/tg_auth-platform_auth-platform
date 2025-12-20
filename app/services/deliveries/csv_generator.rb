# typed: strict

require 'csv'

module Deliveries
  # Generates CSV for Blastengine bulk email import
  #
  # Blastengine insert code requirements:
  # - Format: __key__ (double underscore prefix/suffix)
  # - Key: alphanumeric only (半角英数字) - NO underscores inside!
  #
  # Mapping:
  #   __firstname__  = first_name
  #   __lastname__   = last_name
  #   __fullname__   = full_name (last_name + first_name)
  class CsvGenerator
    extend T::Sig

    sig { params(users: T.untyped).void }
    def initialize(users:)
      @users = users
    end

    sig { returns(String) }
    def generate
      CSV.generate do |csv|
        # Blastengine only accepts alphanumeric keys (no underscores inside)
        csv << %w[email __firstname__ __lastname__ __fullname__]
        @users.each do |user|
          profile = user.user_profile
          first_name = profile&.first_name || ''
          last_name = profile&.last_name || ''
          full_name = "#{last_name} #{first_name}".strip

          csv << [user.email, first_name, last_name, full_name]
        end
      end
    end
  end
end
