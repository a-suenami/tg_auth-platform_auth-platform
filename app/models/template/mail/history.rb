# typed: strict

class Template::Mail::History < ApplicationRecord
  extend T::Sig
  include Multitenancy

  belongs_to :tenant
  belongs_to :template
  belongs_to :version, class_name: 'Template::Mail::Version', optional: true
  belongs_to :actor, class_name: 'Admin', optional: true

  validates :event_type, presence: true
  validates :payload, presence: true

  # Event types
  EVENT_TYPES = T.let(
    {
      draft_created: 'draft_created',
      draft_updated: 'draft_updated',
      published: 'published',
      scheduled: 'scheduled',
      rescheduled: 'rescheduled',
      canceled: 'canceled',
    }.freeze,
    T::Hash[Symbol, String],
  )

  scope :ordered, -> { order(created_at: :desc) }
  scope :for_template, ->(template_id) { where(template_id: template_id) }

  sig { params(template: Template, event_type: String, actor: T.nilable(Admin), version: T.nilable(Template::Mail::Version), payload: T::Hash[Symbol, T.untyped]).returns(Template::Mail::History) }
  def self.log_event(template:, event_type:, actor: nil, version: nil, payload: {})
    create!(
      tenant_id: template.tenant_id,
      template: template,
      event_type: event_type,
      actor: actor,
      version: version,
      payload: payload,
      created_at: Time.current,
    )
  end
end
