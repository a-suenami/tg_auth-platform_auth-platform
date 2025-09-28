# typed: false

module UserStripe
  class CompletePaymentIntentContractService < UserStripe::BaseService
    def initialize(event:)
      @event = event
    end

    def execute
      invoice = @event.data.object

      stripe_record_invoice = StripeRecord::Invoice.find_by(remote_id: invoice.id)
      return unless stripe_record_invoice

      stripe_record_invoice.update!(
        status: invoice.status,
      )

      # 関連するContractを取得（invoiceを通じて）
      contract = stripe_record_invoice&.chargeable&.current_billing_profile&.membership_contract
      contract.update!(
        status: 'active',
      )
      return unless contract

      stripe_record_subscription = stripe_record_invoice&.chargeable

      # 契約完了処理
      UserStripe::CompleteContractService.new.execute(contract, stripe_record_subscription)
    end

    private



    def calculate_recurring_expiry_date(activated_at, plan)
      # recurring_interval_unitとrecurring_interval_countを使用して契約期間を計算
      case plan.recurring_interval_unit
      when 'day'
        activated_at + plan.recurring_interval_count.days
      when 'week'
        activated_at + plan.recurring_interval_count.weeks
      when 'month'
        activated_at + plan.recurring_interval_count.months
      when 'year'
        activated_at + plan.recurring_interval_count.years
      else
        raise Exceptions::Payment::InvalidPlan, "Invalid recurring_interval_unit: #{plan.recurring_interval_unit}"
      end
    end
  end
end
