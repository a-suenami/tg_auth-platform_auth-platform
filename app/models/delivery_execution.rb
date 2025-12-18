# typed: strict

class DeliveryExecution < ApplicationRecord
  extend T::Sig
  include Multitenancy

  MAX_RETRIES = T.let(5, Integer)

  enum :status, {
    queued: 'queued',
    sent: 'sent',
    retrying: 'retrying',
    failed: 'failed',
  }

  belongs_to :tenant
  belongs_to :delivery
  belongs_to :user

  validates :delivery_id, uniqueness: { scope: :user_id }

  scope :scheduled_before, ->(time) { where('scheduled_for <= ?', time) }
  scope :ready_to_send, -> { T.unsafe(queued).where('scheduled_for <= ?', Time.current) }

  sig { params(api_result: T::Hash[String, T.untyped]).void }
  def mark_sent!(api_result = {})
    update!(
      status: 'sent',
      sent_at: Time.current,
      result: api_result,
    )
  end

  # Called when Sidekiq job fails - just increment retry_count
  # Sidekiq handles the actual retry scheduling
  sig { params(error: String, api_result: T::Hash[String, T.untyped]).void }
  def mark_retrying!(error, api_result = {})
    update!(
      status: 'retrying',
      retry_count: retry_count + 1,
      error_message: error,
      result: api_result,
    )
  end

  # Called when max retries exhausted
  sig { params(error: String, api_result: T::Hash[String, T.untyped]).void }
  def mark_failed!(error, api_result = {})
    update!(
      status: 'failed',
      error_message: error,
      result: api_result,
    )
  end

  sig { returns(T::Boolean) }
  def can_retry?
    retry_count < MAX_RETRIES
  end

  sig { returns(T::Boolean) }
  def max_retries_reached?
    retry_count >= MAX_RETRIES
  end
end
