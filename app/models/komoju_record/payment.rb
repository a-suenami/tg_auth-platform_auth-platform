# typed: strict
# frozen_string_literal: true

class KomojuRecord::Payment < ApplicationRecord
  extend T::Sig
  include Multitenancy

  # Associations
  belongs_to :user

  has_one :payment_transaction, class_name: 'Payment::Transaction', as: :chargeable, dependent: :nullify

  # Validations
  validates :remote_id, presence: true, uniqueness: { scope: :tenant_id }
  validates :status, presence: true
  validates :amount, presence: true, numericality: { only_integer: true, greater_than: 0 }

  # Status enum values
  STATUSES = T.let(%w[authorized captured expired cancelled].freeze, T::Array[String])
  validates :status, inclusion: { in: STATUSES }

  sig {
    params(
      amount: Integer,
      currency: String,
      store: KomojuRecord::Client::Payments::KonbiniStore,
      user: User,
      expiry_days: T.nilable(Integer),
    ).returns([T.nilable(KomojuRecord::Payment), T.nilable(KomojuRecord::KomojuError)])
  }
  def self.create_with_konbini!(amount:, currency:, store:, user:, expiry_days: nil)
    params = KomojuRecord::Client::Payments::CreateParams.new(
      external_order_num: SecureRandom.uuid,
      amount: amount,
      currency: currency,
      payment_details: KomojuRecord::Client::Payments::KonbiniParams.new(
        store: store.serialize,
        email: T.must(user.email),
        phone: user.phone_number,
        expiry_days: expiry_days || 3,
        given_name: user.user_profile&.first_name,
        family_name: user.user_profile&.last_name,
      ),
      capture: false,
    )

    settle(params, user: user)
  end

  sig {
    params(
      params: KomojuRecord::Client::Payments::CreateParams,
      user: User,
    ).returns([T.nilable(KomojuRecord::Payment), T.nilable(KomojuRecord::KomojuError)])
  }
  def self.settle(params, user:)
    komoju_error = T.let(nil, T.nilable(KomojuRecord::KomojuError))

    response = begin
      KomojuRecord.client.payments.create(params)
    rescue KomojuRecord::KomojuError => e
      komoju_error = e

      # Try to fetch by external_order_num
      begin
        list_response = KomojuRecord.client.payments.list(external_order_num: params.external_order_num)
        list_response['data']&.first || {}
      rescue StandardError
        {}
      end
    end

    return [nil, komoju_error] if response.blank?

    # Create local payment record
    komoju_payment = new(
      user: user,
      tenant_id: user.tenant_id,
    )
    komoju_payment.assign_response(response)
    komoju_payment.save!

    [komoju_payment, komoju_error]
  end

  # ===========================================================================
  # Instance Methods
  # ===========================================================================

  sig { params(response: T::Hash[String, T.untyped]).returns(KomojuRecord::Payment) }
  def assign_response(response)
    self.remote_id = T.let(response['id'], String)
    self.status = T.let(response['status'], String)
    self.amount = T.let(response['amount'], Integer)
    self.komoju_data = response

    # Extract konbini-specific fields
    payment_details = T.let(response['payment_details'], T.nilable(T::Hash[String, T.untyped]))
    if payment_details
      self.confirmation_code = T.let(payment_details['confirmation_code'], T.nilable(String))

      # Parse payment_deadline if exists (from response root level)
      payment_deadline_str = T.let(response['payment_deadline'], T.nilable(String))
      self.payment_deadline = Time.zone.parse(payment_deadline_str) if payment_deadline_str.present?
    end

    # Set state tracking timestamps
    created_at_str = T.let(response['created_at'], T.nilable(String))
    if created_at_str.present?
      created_time = Time.zone.parse(created_at_str)

      case self.status
      when 'authorized'
        self.authorized_at ||= created_time
      when 'captured'
        self.authorized_at ||= created_time
        self.captured_at ||= Time.zone.now
      when 'expired'
        self.expired_at ||= Time.zone.now
      end
    end

    self
  end

  sig { returns(T::Boolean) }
  def captured?
    status == 'captured' && captured_at.present?
  end

  sig { returns(T::Boolean) }
  def authorized?
    status == 'authorized'
  end

  sig { returns(T::Boolean) }
  def expired?
    status == 'expired' || (payment_deadline.present? && T.must(payment_deadline) < Time.zone.now)
  end

  sig { returns(T::Boolean) }
  def cancelled?
    status == 'cancelled'
  end
end
