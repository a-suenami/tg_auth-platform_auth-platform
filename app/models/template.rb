# typed: strict

class Template < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant

  has_one :template_mail, class_name: 'Template::Mail', dependent: :destroy
  has_many :template_mail_versions, class_name: 'Template::Mail::Version', dependent: :destroy
  has_many :template_mail_histories, class_name: 'Template::Mail::History', dependent: :destroy

  validates :name, presence: true

  scope :with_mail, -> { joins(:template_mail) }

  sig { returns(T.nilable(Integer)) }
  def published_version
    latest_published_version&.version
  end

  sig { returns(Symbol) }
  def state
    return :no_template if template_mail.nil?
    return :draft if template_mail_versions.none?

    latest = latest_version
    return :draft if latest.nil?

    # Check if draft has unpublished changes (different from latest version)
    if mail_template.title.to_s != latest.title.to_s || mail_template.body.to_s != latest.body.to_s
      return :draft
    end

    if latest.public_started_at > Time.current
      :scheduled
    else
      :published
    end
  end

  sig { returns(T.nilable(Template::Mail::Version)) }
  def latest_version
    template_mail_versions.order(version: :desc).first
  end

  sig { returns(T.nilable(Template::Mail::Version)) }
  def latest_published_version
    template_mail_versions
      .where('public_started_at <= :time', time: Time.current)
      .order(version: :desc)
      .first
  end
end
