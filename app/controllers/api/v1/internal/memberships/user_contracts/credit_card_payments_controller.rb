# typed: true
# frozen_string_literal: true

module API::V1::Internal::Memberships::UserContracts
  class CreditCardPaymentsController < API::V1::Internal::Memberships::UserContracts::ApplicationController
    def create
      # 1. memberships_plan_idからMemberships::Planを検索し@membership_planに保存
      @membership_plan = Memberships::Plan.find(params[:memberships_user_contracts][:memberships_plan_id])

      # 2. current_userに紐づくMembershipsUserを検索し、@membership_planに紐づくmembershipにすでに契約していないか確認する
      existing_membership_users = current_user.membership_users.joins(:membership)
                                             .joins('INNER JOIN memberships__plan_components ON memberships.id = memberships__plan_components.membership_id')
                                             .where(memberships__plan_components: { membership_plan_id: @membership_plan.id })

      if existing_membership_users.exists?
        return render json: { error: '既にこのメンバーシッププランに契約しています' }, status: :unprocessable_entity
      end

      # 3. 与えられたmembership_plan.plan_payment_methodにcredit_cartがあるか確認
      payment_method = params[:memberships_user_contracts][:payment_method]
      unless @membership_plan.plan_payment_methods.exists?(payment_type: 'credit_card')
        return render json: { error: '指定された支払い方法はこのプランでは利用できません' }, status: :unprocessable_entity
      end

      # 4. 決済処理を実行与えられたpayment_methodごと異なる。
      user_contract = process_credit_card_payment(@membership_plan)

      # TODO: もしクレカ会社が3DSに対応しておらず、即時決済完了になったら、3DSをスキップして、決済完了とする

      # UserContractをBlueprintでシリアライズ
      render json: Memberships::UserContractBlueprint.render(user_contract), status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: '指定されたメンバーシッププランが見つかりません' }, status: :not_found
    rescue => e
      Rails.logger.error "Membership contract creation failed: #{e.message}"
      render json: { error: 'メンバーシップ契約の作成に失敗しました' }, status: :internal_server_error
    end

    private

    def process_credit_card_payment(membership_plan)
      # クレジットカード決済の実装
      # 実際の実装では、Stripeなどの決済サービスを使用
      payment_method = current_user.valid_stripe_card_payment_method

      unless payment_method
        return { success: false, error: '有効なクレジットカードが登録されていません' }
      end

      # Stripe決済の実装（簡略化）
      # 実際の実装では、StripeRecord::PaymentIntentを使用
      # TODO: priceはmembership_planからひく
      user_contract = UserStripe::CreateMembershipSubscriptionService.new.execute(user: current_user, stripe_record_price: StripeRecord::Price.where(tenant_id: current_user.tenant_id).last,
membership_plan:,)
    end
  end
end
