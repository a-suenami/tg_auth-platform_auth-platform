# typed: false
# frozen_string_literal: true

module UserStripe
  class StripeWebhookHandlerService < UserStripe::BaseService
    def initialize(event)
      @event = event
    end

    def process
      case @event.type
      when 'payment_intent.succeeded'
        # invoice.paidで処理を受ける
      when 'invoice.paid'
        invoice = @event.data.object
        case invoice.billing_reason
        when 'subscription_create'
          # 初回課金
          handle_invoice_paid_on_subscription_create
        when 'subscription_cycle'
          # 自動更新の確定処理
          handle_invoice_paid_on_subscription_cycle(type: 'subscription_cycle')
        when 'subscription_update'
          # subscription_scheduleで自動切り替え時にここに入る
          # TODO: もしかして、subscription updateでも来ちゃう？
          handle_invoice_paid_on_subscription_cycle(type: 'subscription_update')
          # else
          # manual / subscription_threshold など
        end
      else
        Rails.logger.info "Unhandled webhook event: #{@event.type}"
      end
    rescue => e
      Sentry.capture_exception(e)
      raise e
    end

    private

    # TODO: 冪等な処理にする
    def handle_invoice_paid_on_subscription_create
      UserStripe::CompletePaymentIntentContractService.new(event: @event).execute
    end


    def handle_invoice_paid_on_subscription_cycle(_type:)
      UserStripe::RenewMembershipSubscriptionService.new(event: @event).execute
    end


  end
end
