# typed: strict
# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  extend T::Helpers
  # extend Enumerize
  abstract!

  primary_abstract_class
end
