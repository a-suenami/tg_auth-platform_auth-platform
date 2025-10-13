# typed: strict

class Template::Mail < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :template

  # Draft table - no state logic here
  # State is determined by template.template_mail_versions
end
