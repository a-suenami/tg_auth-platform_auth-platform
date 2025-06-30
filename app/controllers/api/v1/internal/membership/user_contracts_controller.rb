# typed: true
# frozen_string_literal: true

module API::V1::Internal::Membership
  class UserContractsController < API::V1::Internal::ApplicationController
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

      # 3. 与えられたpayment_methodが与えられたmembership_plan.plan_payment_methodにあるか確認
      payment_method = params[:memberships_user_contracts][:payment_method]
      unless @membership_plan.plan_payment_methods.exists?(payment_type: payment_method)
        return render json: { error: '指定された支払い方法はこのプランでは利用できません' }, status: :unprocessable_entity
      end

      # 4. 決済処理を実行与えられたpayment_methodごと異なる。
      payment_result = process_payment(payment_method, @membership_plan)

      unless payment_result[:success]
        return render json: { error: payment_result[:error] }, status: :unprocessable_entity
      end

      # 5. 決済が完了した場合はUserContractsを保存し、memberships_planに紐づいたメンバーシップをuserと繋げる(MembershipUserを作成)
      ActiveRecord::Base.transaction do
        # UserContractを作成
        expires_at = calculate_expires_at(@membership_plan)
        user_contract = current_user.membership_user_contracts.create!(
          tenant_id: current_user.tenant_id,
          expires_at:,
          cancel_at_period_end: false,
        )

        # ActivationSourceを作成
        activation_source = Memberships::ActivationSource.create!(
          tenant_id: current_user.tenant_id,
          user: current_user,
          membership_plan: @membership_plan,
          memberships__user_contract: user_contract,
          payment_type: payment_method,
          activated_at: Time.current,
          expires_at:,
        )

        # UserContractにActivationSourceを紐付け
        user_contract.update!(last_membership_activation_source: activation_source)

        # MembershipUserを作成（プランに紐づく全てのメンバーシップに対して）
        @membership_plan.memberships.each do |membership|
          current_user.membership_users.create!(
            tenant_id: current_user.tenant_id,
            membership:,
            expires_at:,
          )
        end
      end

      render json: { message: 'メンバーシップ契約が完了しました' }, status: :created
    rescue ActiveRecord::RecordNotFound
      render json: { error: '指定されたメンバーシッププランが見つかりません' }, status: :not_found
    rescue => e
      Rails.logger.error "Membership contract creation failed: #{e.message}"
      render json: { error: 'メンバーシップ契約の作成に失敗しました' }, status: :internal_server_error
    end

    private

    def process_payment(payment_method, membership_plan)
      case payment_method
      when 'credit_card'
        process_credit_card_payment(membership_plan)
      when 'convenience'
        process_convenience_payment(membership_plan)
      when 'campaign_code'
        process_campaign_code_payment(membership_plan)
      when 'external_linkage'
        process_external_linkage_payment(membership_plan)
      else
        { success: false, error: 'サポートされていない支払い方法です' }
      end
    end

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
      UserStripe::CreateMembershipSubscriptionService.new.execute(user: current_user, stripe_record_price: StripeRecord::Price.where(tenant_id: current_user.tenant_id).last,
membership_plan:,)
      # { success: true }
    end

    def process_convenience_payment(_membership_plan)
      # コンビニ決済の実装
      # 実際の実装では、コンビニ決済サービスを使用
      { success: true }
    end

    def process_campaign_code_payment(_membership_plan)
      # キャンペーンコード決済の実装
      # 実際の実装では、キャンペーンコードの検証を行う
      { success: true }
    end

    def process_external_linkage_payment(_membership_plan)
      # 外部連携決済の実装
      # 実際の実装では、外部サービスの連携を行う
      { success: true }
    end

    def calculate_expires_at(membership_plan)
      if membership_plan.recurrence
        # 定期課金（サブスクリプション）の場合
        case membership_plan.validity_period
        when 'month'
          1.month.from_now
        when 'year'
          1.year.from_now
        else
          1.month.from_now # デフォルト
        end
      else
        # 買い切りの場合
        case membership_plan.validity_period
        when 'month'
          1.month.from_now
        when 'year'
          1.year.from_now
        else
          1.month.from_now # デフォルト
        end
      end
    end
  end
end
