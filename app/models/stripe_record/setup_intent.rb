# typed: strict

# ==============================================================================
# app/models/stripe_record/setup_intent.rb
# ==============================================================================
class StripeRecord
  class SetupIntent < ApplicationRecord
    extend T::Sig
    include Multitenancy
    include StripeConnectable

    self.inheritance_column = :_type_disabled

    belongs_to :user

    has_one :payment_method, class_name: 'StripeRecord::PaymentMethod'
    has_one :subscription, class_name: 'StripeRecord::Subscription', dependent: :nullify, inverse_of: :pending_setup_intent

    validates :remote_id, presence: true, uniqueness: true

    class StatusEnum < T::Enum
      enums do
        Canceled = new('canceled')
        Processing = new('processing')
        RequiresAction = new('requires_action')
        RequiresConfirmation = new('requires_confirmation')
        RequiresPaymentMethod = new('requires_payment_method')
        Succeeded = new('succeeded')
      end
    end

    class UsageEnum < T::Enum
      enums do
        OffSession = new('off_session')
        OnSession = new('on_session')
      end
    end

    enumerize :status, enum_class: StatusEnum
    enumerize :usage, enum_class: UsageEnum

    class << self
      extend T::Sig

      sig { params(tenant_stripe_account: Tenant::StripeAccount, user: User).returns(Mangrove::Result[StripeRecord::SetupIntent, Stripe::StripeError]) }
      def api_create_card_setup_intent(tenant_stripe_account:, user:)
        result = StripeRecord::Client::SetupIntent.create(
          {
            payment_method_types: ['card'],
            usage: :off_session,
            payment_method_options: {
              card: {
                request_three_d_secure: :automatic,
              },
            },
          },
          stripe_account_id: tenant_stripe_account.stripe_account_id_if_needed,
          api_key: tenant_stripe_account.api_key,
        )

        return Mangrove::Result.err(result.err_inner) if result.is_a?(Mangrove::Result::Err)

        remote_setup_intent = result.ok_inner

        setup_intent = self.new(
          user:,
          activated_at: nil,
          api_key_account: tenant_stripe_account.api_key_account,
        )
        # Connect のときだけ connect_account と charge_type を設定する
        if tenant_stripe_account.stripe_account&.connect_account?
          setup_intent.connect_account = tenant_stripe_account.stripe_account
          setup_intent.charge_type     = tenant_stripe_account.charge_type
        end
        setup_intent.assign_remote_attributes(remote_setup_intent)

        setup_intent.save!

        Mangrove::Result.ok(setup_intent)
      end
    end

    sig { params(remote_setup_intent: Stripe::SetupIntent).returns(StripeRecord::SetupIntent) }
    def assign_remote_attributes(remote_setup_intent)
      self.remote_id = remote_setup_intent.id
      self.client_secret = remote_setup_intent.client_secret
      self.on_behalf_of_id = remote_setup_intent.on_behalf_of
      self.payment_method_id = remote_setup_intent.payment_method
      self.status = remote_setup_intent.status
      self.usage = remote_setup_intent.usage

      self
    end

    class CreateCardPaymentMethodResult
      extend Mangrove::Enum

      variants do
        variant Succeeded, StripeRecord::PaymentMethod
        variant AlreadyCreated, NilClass
        variant InvalidStatus, StatusEnum
        variant InvalidPaymentMethodType, String
        variant StripeError, Stripe::StripeError
      end
    end

    # カード登録に成功していたら自身から PaymentMethod を作成する
    sig { returns(CreateCardPaymentMethodResult) }
    def create_card_payment_method
      user = T.must(self.user)
      api_key_account = T.must(self.api_key_account)
      api_key = T.must(api_key_account.api_key)

      # この段階で payment_customer_id がないことはないはずだが
      remote_customer_id = T.must(user.payment_customer_id)

      if self.payment_method.present? || self.activated_at.present?
        return CreateCardPaymentMethodResult::AlreadyCreated.new(nil)
      end

      # 1. 最新の SetupIntent を引く
      result = StripeRecord::Client::SetupIntent.retrieve(self.remote_id, stripe_account_id: self.stripe_account_id_if_needed, api_key:)
      return CreateCardPaymentMethodResult::StripeError.new(result.err_inner) if result.is_a?(Mangrove::Result::Err)

      remote_setup_intent = result.ok_inner

      # 2. 登録が完了していなければエラー
      remote_status = remote_setup_intent.status
      if remote_status != StripeRecord::SetupIntent::StatusEnum::Succeeded.serialize
        status_enum = StatusEnum.deserialize(remote_status)
        return CreateCardPaymentMethodResult::InvalidStatus.new(status_enum)
      end

      # 3. PaymentMethod (card) を引く
      result = StripeRecord::Client::PaymentMethod.retrieve(T.must(remote_setup_intent.payment_method), stripe_account_id: self.stripe_account_id_if_needed, api_key:)
      return CreateCardPaymentMethodResult::StripeError.new(result.err_inner) if result.is_a?(Mangrove::Result::Err)

      remote_payment_method = result.ok_inner

      # card 以外の payment method はエラー
      if remote_payment_method.type != 'card'
        return CreateCardPaymentMethodResult::InvalidPaymentMethodType.new(remote_payment_method.type)
      end

      # 4. 既存の card を detach して無効化する
      detached_result = user.detach_stripe_payment_methods
      return CreateCardPaymentMethodResult::StripeError.new(detached_result.err_inner) if detached_result.is_a?(Mangrove::Result::Err)

      # ------------------------------------------------------------------------
      # 新規登録ではなく変更の場合、ここ以降で失敗した場合過去の登録済みカードはすでに detached されており
      # 登録カードが存在しない状態になるのでそのことに留意した処理を書くこと
      # ------------------------------------------------------------------------

      # 5. ActiveRecord の object を作成する
      payment_method = self.build_payment_method(
        remote_id: remote_payment_method.id,
        user: self.user,
        type: remote_payment_method.type,
        billing_details: remote_payment_method.billing_details,
        card: remote_payment_method.card,
        customer_id: remote_customer_id,
        api_key_account: self.api_key_account,
        connect_account: self.connect_account,
        charge_type: self.charge_type,
      )

      begin
        ApplicationRecord.transaction do
          # 6. PaymentMethod を transaction の中で永続化する
          # 万が一この先 API call で例外が発生したら rollback されるので安全
          payment_method.save!
          self.update_columns(activated_at: Time.zone.now)

          # 7. card を customer に紐付ける
          attached_result = StripeRecord::Client::PaymentMethod.attach(
            remote_payment_method.id,
            { customer: remote_customer_id },
            stripe_account_id: self.stripe_account_id_if_needed,
            api_key:,
          )
          raise CreateCardPaymentMethodResult::StripeError, attached_result.err_inner if attached_result.is_a?(Mangrove::Result::Err)

          remote_payment_method = attached_result.ok_inner

          # 8. subscription決済のために customer の default_payment_method を更新する
          StripeRecord::Client::Customer.update(
            remote_customer_id,
            { invoice_settings: { default_payment_method: remote_payment_method.id } },
            stripe_account_id: self.stripe_account_id_if_needed,
            api_key:,
          )
        end
      rescue Stripe::StripeError => e
        return CreateCardPaymentMethodResult::StripeError.new(e)
      end

      CreateCardPaymentMethodResult::Succeeded.new(payment_method)
    end
  end
end
