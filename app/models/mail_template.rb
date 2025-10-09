# typed: strict

class MailTemplate < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :template

  # Draft table - no state logic here
  # State is determined by template.mail_template_versions
end
