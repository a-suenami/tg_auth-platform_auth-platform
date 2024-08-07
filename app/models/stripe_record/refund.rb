# typed: strict

# ==============================================================================
# app/models/stripe_record/refund.rb
# ==============================================================================
class StripeRecord
  class Refund < ApplicationRecord
    extend T::Sig
    include Multitenancy
    include StripeConnectable

    belongs_to :user
    belongs_to :payment_intent

    class StatusEnum < T::Enum
      enums do
        Pending = new('pending')
        RequiresAction = new('requires_action')
        Succeeded = new('succeeded')
        Failed = new('failed')
        Canceled = new('canceled')
      end
    end

    enumerize :currency, enum_class: AuthPlatform::Currency
    enumerize :status, enum_class: StatusEnum

    validates :remote_id, presence: true, uniqueness: true
    validates :currency, :amount, :status, presence: true

    class << self
      extend T::Sig

      sig {
        params(
          payment_intent: StripeRecord::PaymentIntent,
          note: String, # 返金理由のメモ（metadata に保存される）
          amount: T.nilable(Integer),
        ).returns(Mangrove::Result[StripeRecord::Refund, Stripe::StripeError])
      }
      def api_create(payment_intent:, note:, amount: nil)
        params = {
          payment_intent: payment_intent.remote_id,
          metadata: { note: },
        }
        params[:amount] = amount if amount.present?

        # Connect の場合
        if payment_intent.transfer_group.present? # デスティネーション支払い
          params[:reverse_transfer] = true
          params[:refund_application_fee] = true
        elsif payment_intent.application_fee_amount.present? # ダイレクト支払い
          params[:refund_application_fee] = true
        end

        api_key_account = T.must(payment_intent.api_key_account)
        api_key = T.must(api_key_account.api_key)

        # stripe_account_id はダイレクト支払いのときだけ String を渡す（それ以外の場合は nil が渡される）
        result = StripeRecord::Client::Refund.create(params, stripe_account_id: payment_intent.stripe_account_id_if_needed, api_key:)

        T.assert_type!(result, Mangrove::Result[Stripe::Refund, Stripe::StripeError])

        return Mangrove::Result.err(result.err_inner) if result.is_a?(Mangrove::Result::Err)

        stripe_refund = self.construct_from_remote(user: T.must(payment_intent.user), payment_intent:, remote_refund: result.ok_inner)
        stripe_refund.save!
        payment_intent.api_refresh(auto_save: true)

        Mangrove::Result.ok(stripe_refund)
      end

      sig { params(user: User, payment_intent: StripeRecord::PaymentIntent, remote_refund: Stripe::Refund).returns(StripeRecord::Refund) }
      def construct_from_remote(user:, payment_intent:, remote_refund:)
        refund = self.new(
          remote_id: remote_refund.id,
          user:,
          payment_intent:,
          tenant_id: user.tenant_id,
          api_key_account: payment_intent.api_key_account,
          connect_account: payment_intent.connect_account,
          charge_type: payment_intent.charge_type,
        )
        refund.assign_remote_attributes(remote_refund)
        refund
      end
    end

    sig { params(remote_refund: Stripe::Refund).returns(StripeRecord::Refund) }
    def assign_remote_attributes(remote_refund)
      self.amount = remote_refund.amount
      self.balance_transaction_id = remote_refund.balance_transaction
      self.currency = remote_refund.currency
      self.destination_details = remote_refund.destination_details.as_json
      self.metadata = remote_refund.metadata.as_json
      self.reason = remote_refund.reason
      self.receipt_number = remote_refund.receipt_number
      self.source_transfer_reversal_id = remote_refund.source_transfer_reversal
      self.status = remote_refund.status
      self.transfer_reversal_id = remote_refund.transfer_reversal
      self.created = remote_refund.created
      self.created_at = Time.zone.at(remote_refund.created)

      self
    end
  end
end
