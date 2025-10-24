# typed: true
# frozen_string_literal: true

module API::V1::Internal::Membership::Contracts
  class CreditCardPaymentsController < API::V1::Internal::Membership::Contracts::ApplicationController
    def create
      @membership_plan = Membership::Plan.find(memberships_contracts_params[:membership_plan_id])
      contract = Membership::Contracts::CreateService.new.execute(user: current_user, membership_plan: @membership_plan, payment_method: 'credit_card')

      # TODO: もしクレカ会社が3DSに対応しておらず、即時決済完了になったら、3DSをスキップして、決済完了とする

      # ContractをBlueprintでシリアライズ
      render json: Membership::ContractBlueprint.render(contract, view: :detailed), status: :created
    end

    # 複数プランを同時契約（すべてオフセッション前提）
    def create_multiple
      ids = memberships_contracts_params[:membership_plan_ids]
      # 空の配列や空文字列を含む配列をチェック
      if ids.blank? || ids.empty? || ids.all?(&:blank?)
        raise Exceptions::Payment::InvalidParams
      end

      membership_plans = Membership::Plan.where(id: ids)
      if membership_plans.size != ids.size
        raise Exceptions::Payment::InvalidParams
      end

      contracts = []
      ActiveRecord::Base.transaction do
        membership_plans.each do |plan|
          contract = UserStripe::CreateMembershipSubscriptionService.new.execute(user: current_user, membership_plan: plan, off_session: true)
          contracts << contract
        end
      end

      render json: Membership::ContractBlueprint.render(contracts, view: :detailed), status: :created
    rescue Stripe::StripeError => e
      Sentry.capture_exception(e)
      render json: { error: { code: 'stripe_error', message: e.message } }, status: :bad_request
    rescue => e
      Sentry.capture_exception(e)
      render json: { error: { code: 'unknown_error', message: e.message } }, status: :internal_server_error
    end

    # 決済後完了コールバック（フロントからの明示的呼び出し想定）
    # Params: { contract_id: UUID }
    def complete
      contract = Membership::Contract.find(params[:contract_id])

      payment_transaction = contract.payment_transactions.order(created_at: :desc).first
      unless payment_transaction
        render json: { error: { code: 'transaction_not_found', message: '関連する決済が見つかりません' } }, status: :bad_request
        return
      end

      chargeable = payment_transaction.chargeable

      # Stripe 側のステータス確認
      case chargeable
      when StripeRecord::PaymentIntent
        result = chargeable.api_refresh
        if result.is_a?(Mangrove::Result::Err)
          render json: { error: { code: 'stripe_error', message: result.err_inner.message } }, status: :bad_request
          return
        end
        if chargeable.status != StripeRecord::PaymentIntent::StatusEnum::Succeeded
          render json: { error: { code: 'payment_not_succeeded', message: '決済が完了していません' } }, status: :bad_request
          return
        end
      when StripeRecord::SetupIntent
        result = chargeable.api_refresh
        if result.is_a?(Mangrove::Result::Err)
          render json: { error: { code: 'stripe_error', message: result.err_inner.message } }, status: :bad_request
          return
        end
        if chargeable.status != StripeRecord::SetupIntent::StatusEnum::Succeeded
          render json: { error: { code: 'setup_not_succeeded', message: 'カード認証が完了していません' } }, status: :bad_request
          return
        end
      else
        render json: { error: { code: 'unsupported_chargeable', message: '対象外の決済オブジェクトです' } }, status: :bad_request
        return
      end

      # 成功していれば契約完了処理
      UserStripe::CompleteContractService.new.execute(contract)

      render json: Membership::ContractBlueprint.render(contract.reload, view: :detailed), status: :ok
    end

    private

    def memberships_contracts_params
      params.require(:memberships_contracts).permit(:membership_plan_id, membership_plan_ids: [])
    end
  end
end
