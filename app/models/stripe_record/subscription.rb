# typed: false

# ==============================================================================
# app - models - app stripe subscription
# ==============================================================================
class StripeRecord
  class Subscription < ApplicationRecord
    include Multitenancy

    belongs_to :user
    belongs_to :product, class_name: 'StripeRecord::Product'
    belongs_to :price, class_name: 'StripeRecord::Price'
    belongs_to :pending_setup_intent, class_name: 'StripeRecord::SetupIntent', optional: true, inverse_of: :subscription

    # has_one :subscription, as: :chargeable

    has_many :invoices, inverse_of: :chargeable
    has_many :subscription_items, class_name: 'StripeRecord::SubscriptionItem', dependent: :destroy

    has_many :billing_profiles, inverse_of: :chargeable, dependent: :nullify, class_name: 'Memberships::BillingProfile'
    # billing_profileの中でもphaseがcurrentのものを取得する
    has_one :current_billing_profile, -> { where(phase: :current) }, class_name: 'Memberships::BillingProfile', inverse_of: :chargeable, dependent: :nullify
    has_one :upcoming_billing_profile, -> { where(phase: :upcoming) }, class_name: 'Memberships::BillingProfile', inverse_of: :chargeable, dependent: :nullify
    has_many :subscription_schedules, class_name: 'StripeRecord::SubscriptionSchedule', dependent: :nullify
    has_one :last_subscription_schedule, -> { order(created_at: :desc) }, class_name: 'StripeRecord::SubscriptionSchedule', dependent: :nullify, inverse_of: :subscription

    scope :active, -> { where(status: :active) }

    # 作成から incomplete 23時間以内のもの
    # 23時間以上経過した incomplete は stripe 上では incomplete_expired になる
    scope :action_may_be_required, lambda { |now = Time.zone.now|
      where(status: :trialing).or(
        where(status: :incomplete).where('stripe_record_subscriptions.created_at > ?', now - 23.hours),
      ).order(created_at: :desc)
    }

    # 契約時に無料トライアルのプレビューに使用する
    attribute :trial_status,   :string
    attribute :trial_end_date, :date

    # validates :product, uniqueness: { scope: [:tenant_id, :user_id], conditions: -> { where(status: :active) } }, if: :active?
    # validates :plan_id, uniqueness: { scope: [:tenant_id, :user_id], conditions: -> { where(status: :active) } }, if: :active?

    enumerize :status, in: [:active, :past_due, :canceled, :incomplete, :incomplete_expired, :trialing, :unpaid], default: :active, predicates: true
    enumerize :trial_status, in: [:none, :available, :unavailable]

    def refresh!
      StripeRecord::Subscription.transaction do
        stripe_subscription = self.fetch_stripe_subscription
        self.update!(status: stripe_subscription.status)

        if stripe_subscription.status == 'canceled'
          subscription&.update(expires_at: Time.zone.at(stripe_subscription.canceled_at))
        else
          subscription&.update(expires_at: Time.zone.at(stripe_subscription.current_period_end))
        end

        stripe_subscription
      end
    end

    def fetch_stripe_subscription
      return @stripe_subscription if @stripe_subscription.present?

      @stripe_subscription ||= Stripe::Subscription.retrieve(
        { id: self.stripe_subscription_id, expand: ['latest_invoice.confirmation_secret', 'pending_setup_intent'] },
        AppStripe.configuration,
      )

      @stripe_subscription
    end

    def requires_action?
      stripe_subscription = self.fetch_stripe_subscription

      case stripe_intent_type
      when :setup_intent
        true
      when :payment_intent
        stripe_subscription.latest_invoice.status != 'paid'
      end
    end

    def stripe_intent_type
      stripe_subscription = self.fetch_stripe_subscription

      if stripe_subscription.pending_setup_intent.present?
        :setup_intent
      elsif stripe_subscription.latest_invoice.payment_intent.present?
        :payment_intent
      end
    end

    def stripe_intent_client_secret
      stripe_subscription = self.fetch_stripe_subscription

      case stripe_intent_type
      when :setup_intent
        stripe_subscription.pending_setup_intent.client_secret
      when :payment_intent
        stripe_subscription.latest_invoice.confirmation_secret.client_secret
      end
    end
  end
end
