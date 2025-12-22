# typed: strict

# ==============================================================================
# app - controllers - api - v1 - private - me - cards controller
# ==============================================================================
module API::V1::Internal
  class Me::CardsController < ApplicationController
    sig { void }
    def show
      card_payment_gateway = T.must(Tenant.current!.card_payment_gateway)

      case card_payment_gateway.enum
      when Tenant::CardPaymentGatewayEnum::Stripe
        card = current_user.valid_stripe_card_payment_method!
      else
        T.absurd(card_payment_gateway)
      end

      render json: StripeRecord::PaymentMethodBlueprint.render(card)
    end

    # Stripe ではカード登録を始めるためにまず SetupIntent の client_secret が必要となるのでここで SetupIntent を作成する
    # その後カード登録が完了したら update を呼び出す
    # Stripe 上は client 側でカード登録が成功した時点でカード（PaymentMethod）の登録が完了しているが WebHook を利用しないと登録完了を検知できず面倒なので
    # Slash Gift 側としては完了後 update を呼ばれるまで登録されたカードを有効として扱わないこととする
    # 一定時間経っても update が呼ばれない場合は非同期でカードを削除する
    sig { void }
    def create_setup_intent
      payment_customer_id = current_user.payment_customer_id

      if payment_customer_id.blank?
        # まだ Stripe::Customer が無ければ作成する
        current_user.create_stripe_customer(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account))
        current_user.payment_customer_id
      end

      result = StripeRecord::SetupIntent.api_create_card_setup_intent(tenant_stripe_account: T.must(Tenant.current!.tenant_stripe_account), user: current_user)
      if result.is_a?(Mangrove::Result::Err)
        render json: { error: { code: 'stripe_error', message: result.err_inner.message } }, status: :bad_request
        return
      end

      setup_intent = result.ok_inner

      render json: StripeRecord::SetupIntentBlueprint.render(setup_intent, view: :normal), status: :created
    end

    # card 情報がなければ作成し、あれば上書きする
    sig { void }
    def update
      card_payment_gateway = T.must(Tenant.current!.card_payment_gateway)

      case card_payment_gateway.enum
      when Tenant::CardPaymentGatewayEnum::Stripe
        stripe_setup_intent_id = params.require(:setup_intent_id)
        setup_intent = current_user.stripe_setup_intents.find_by!(remote_id: stripe_setup_intent_id)
        result = T.let(setup_intent.create_card_payment_method, StripeRecord::SetupIntent::CreateCardPaymentMethodResult)

        case result
        when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::Succeeded
          card = result.inner
        when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::AlreadyCreated
          raise Exceptions::Payment::Stripe::SetupIntent::AlreadyCreated
        when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::InvalidStatus
          raise Exceptions::Payment::Stripe::SetupIntent::NotCompleted
        when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::InvalidPaymentMethodType
          raise Exceptions::Payment::Stripe::SetupIntent::NotCard
        when StripeRecord::SetupIntent::CreateCardPaymentMethodResult::StripeError
          raise result.inner
        else
          T.absurd(result)
        end
      else
        T.absurd(card_payment_gateway)
      end

      T.assert_type!(card, StripeRecord::PaymentMethod)

      render json: StripeRecord::PaymentMethodBlueprint.render(card)
    end

    sig { void }
    def create_off_session_setup_intent
      # もし既存のカードがないならエラー
      if current_user.valid_stripe_card_payment_method.blank?
        raise Exceptions::Payment::CardMissing
      end

      tenant_stripe_account = Tenant.current!.tenant_stripe_account
      result = StripeRecord::SetupIntent.api_create_off_session_setup_intent(tenant_stripe_account: T.must(tenant_stripe_account), user: current_user)

      if result.is_a?(Mangrove::Result::Err)
        render json: { error: { code: 'stripe_error', message: result.err_inner.message } }, status: :bad_request
        return
      end

      setup_intent = result.ok_inner
      render json: StripeRecord::SetupIntentBlueprint.render(setup_intent, view: :normal), status: :created
    end

    sig { void }
    def complete_off_session_card
      stripe_setup_intent_id = params.require(:setup_intent_id)
      setup_intent = current_user.stripe_setup_intents.find_by!(remote_id: stripe_setup_intent_id)

      result = T.cast(setup_intent.complete_off_session_card, T.any(
                                                                StripeRecord::SetupIntent::CompleteOffSessionCardResult::Succeeded,
        StripeRecord::SetupIntent::CompleteOffSessionCardResult::InvalidStatus,
        StripeRecord::SetupIntent::CompleteOffSessionCardResult::StripeError,
                                                              ),)

      case result
      when StripeRecord::SetupIntent::CompleteOffSessionCardResult::Succeeded
        setup_intent = result.inner
      when StripeRecord::SetupIntent::CompleteOffSessionCardResult::InvalidStatus
        raise Exceptions::Payment::Stripe::SetupIntent::NotCompleted
      when StripeRecord::SetupIntent::CompleteOffSessionCardResult::StripeError
        raise result.inner
      else
        T.absurd(result)
      end

      T.assert_type!(setup_intent, StripeRecord::SetupIntent)

      render json: StripeRecord::SetupIntentBlueprint.render(setup_intent, view: :normal)
    end

    sig { void }
    def destroy
      card_payment_gateway = T.must(Tenant.current!.card_payment_gateway)

      case card_payment_gateway.enum
      when Tenant::CardPaymentGatewayEnum::Stripe
        detached_result = current_user.detach_stripe_payment_methods
        raise detached_result.err_inner if detached_result.is_a?(Mangrove::Result::Err)

        T.cast(detached_result.ok_inner, TrueClass)
      else
        T.absurd(card_payment_gateway)
      end

      render json: nil, status: :no_content
    end
  end
end
