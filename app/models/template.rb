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
  scope :ordered, -> { order(created_at: :desc) }
  scope :search_by_name, lambda { |term|
    return all if term.blank?

    where(arel_table[:name].lower.matches("%#{sanitize_sql_like(term.downcase)}%"))
  }

  sig { returns(T.nilable(Integer)) }
  def published_version
    latest_published_version&.version
  end

  sig { returns(Symbol) }
  def state
    return :no_template if template_mail.nil?

    # Use preloaded data if available to avoid N+1 queries
    has_versions = if template_mail_versions.loaded?
                     template_mail_versions.any?
                   else
                     template_mail_versions.exists?
                   end
    return :draft unless has_versions

    latest = latest_version
    return :draft if latest.nil?

    # Check if draft has unpublished changes (different from latest version)
    if T.must(template_mail).title.to_s != latest.title.to_s || T.must(template_mail).body.to_s != latest.body.to_s
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
    if template_mail_versions.loaded?
      template_mail_versions.max_by(&:version)
    else
      template_mail_versions.order(version: :desc).first
    end
  end

  sig { returns(T.nilable(Template::Mail::Version)) }
  def latest_published_version
    now = Time.current
    if template_mail_versions.loaded?
      template_mail_versions
        .select { |v| v.public_started_at <= now }
        .max_by(&:version)
    else
      template_mail_versions
        .where('public_started_at <= :time', time: now)
        .order(version: :desc)
        .first
    end
  end
end
