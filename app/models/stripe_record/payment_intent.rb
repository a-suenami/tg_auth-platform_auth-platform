# typed: strict

# ==============================================================================
# app/models/stripe_record/payment_intent.rb
# ==============================================================================
# 廃止予定
# Invoiceが複数のPaymentIntentを持つようになり、管理が面倒なので
# Subscription以外では使うかも？と思ったので残している
class StripeRecord
  class PaymentIntent < ApplicationRecord
    extend T::Sig
    include Multitenancy
    include StripeConnectable

    ACTIVE_DURATION = T.let(1.hour, ActiveSupport::Duration)

    belongs_to :user
    belongs_to :invoice, class_name: 'StripeRecord::Invoice'
    belongs_to :latest_charge, class_name: 'StripeRecord::Charge', optional: true
    belongs_to :api_key_account, class_name: 'StripeRecord::Account'

    has_many :refunds, dependent: :restrict_with_exception

    scope :active, lambda {
      where(
        status: [
          StatusEnum::Processing.serialize,
          StatusEnum::RequiresAction.serialize,
          StatusEnum::RequiresCapture.serialize,
          StatusEnum::RequiresConfirmation.serialize,
        ],
      ).where('created_at >= ?', ACTIVE_DURATION.ago)
    }
    scope :inactive, lambda {
      where(
        status: [
          StatusEnum::Processing.serialize,
          StatusEnum::RequiresAction.serialize,
          StatusEnum::RequiresCapture.serialize,
          StatusEnum::RequiresConfirmation.serialize,
          StatusEnum::RequiresPaymentMethod.serialize,
        ],
      ).where('created_at < ?', ACTIVE_DURATION.ago.ago(5.minutes)) # 5分は念のためのバッファ
    }

    class StatusEnum < T::Enum
      enums do
        Canceled = new('canceled')
        Processing = new('processing')
        RequiresAction = new('requires_action')
        RequiresCapture = new('requires_capture')
        RequiresConfirmation = new('requires_confirmation')
        RequiresPaymentMethod = new('requires_payment_method')
        Succeeded = new('succeeded')
      end
    end

    enumerize :currency, enum_class: AuthPlatform::Currency
    enumerize :status, enum_class: StatusEnum

    validates :remote_id, presence: true, uniqueness: true
    validates :currency, :amount, :status, presence: true

    class UsualParams < T::Struct
      # 通常の決済専用のパラメーター
      # Stripe の account 情報以外特にないのでそれだけ
      prop :tenant_stripe_account, Tenant::StripeAccount
    end

    class ConnectParams < T::Struct
      # Connect 決済専用のパラメーター
      prop :tenant_stripe_account, Tenant::StripeAccount
      prop :charge_type, Tenant::StripeAccount::ChargeTypeEnum
      prop :fee_rate, BigDecimal
    end

    class << self
      extend T::Sig

      # - 3D セキュア無効の場合
      #     off_session は true でサーバー間の通信だけで決済を行う
      #     作成のタイミングでキャプチャまで取られる（厳密にはオーソリだけ取得してキャプチャは Stripe 側で非同期に行われる）
      #     なので在庫確保などの処理が終わり、決済が確定しても問題ないタイミングで作成を呼び出す必要がある
      #     逆に作成に失敗したら rollback を起こすなどして在庫を戻す必要がある
      # - 3D セキュア有効の場合
      #     off_session は false でエンドユーザーとの interactive な決済フローがあり得る決済を行う
      #     3D セキュア対応カードでなおかつ frictionless フローに入らなかった場合は 3D セキュアの認証をエンドユーザーに求める
      #     その場合作成のタイミングではオーソリも何も取られていない状態で、3D セキュアに成功すると自動でオーソリが取得される
      #     ただしキャプチャは取られないので手動でキャプチャを行わないといけない
      #     3D セキュア非対応のカードや frictionless フローに入った場合は interactive な決済フローは行われない
      #     その場合は作成タイミングでオーソリまで取得される
      #     ただしこちらもキャプチャは取られないので手動でキャプチャを行わないといけない

      sig {
        params(
          payment_method: StripeRecord::PaymentMethod,
          amount: Integer,
          currency: AuthPlatform::Currency,
          request_three_d_secure: StripeRecord::Request3DS,
          specific_params: T.any(ConnectParams, UsualParams),
          metadata: T::Hash[T.untyped, T.untyped],
        ).returns(Mangrove::Result[StripeRecord::PaymentIntent, Stripe::StripeError])
      }
      def api_create_payment_intent_for(payment_method:, amount:, currency:, request_three_d_secure:, specific_params:, metadata: {})
        user = T.must(payment_method.user)

        result = case specific_params
        when UsualParams
          StripeRecord::PaymentIntent.api_create_payment_intent(
            tenant_stripe_account: specific_params.tenant_stripe_account,
            payment_method:,
            amount:,
            currency:,
            user:,
            request_three_d_secure:,
            metadata:,
          )
        when ConnectParams
          StripeRecord::PaymentIntent.api_create_connect_payment_intent(
            tenant_stripe_account: specific_params.tenant_stripe_account,
            charge_type: specific_params.charge_type,
            fee_rate: specific_params.fee_rate,
            payment_method:,
            amount:,
            currency:,
            user:,
            request_three_d_secure:,
            metadata:,
          )
        else
          T.absurd(specific_params)
        end

        result
      end

      # 通常の決済（Connect の利用なし）
      sig {
        params(
          tenant_stripe_account: Tenant::StripeAccount,
          payment_method: StripeRecord::PaymentMethod,
          amount: Integer,
          currency: AuthPlatform::Currency,
          user: User,
          request_three_d_secure: StripeRecord::Request3DS,
          metadata: T::Hash[T.untyped, T.untyped],
        ).returns(Mangrove::Result[StripeRecord::PaymentIntent, Stripe::StripeError])
      }
      def api_create_payment_intent(tenant_stripe_account:, payment_method:, amount:, currency:, user:, request_three_d_secure:, metadata: {})
        tenant = T.must(tenant_stripe_account.tenant)
        api_key = tenant_stripe_account.api_key

        params = {
          amount:,
          currency: currency.serialize,
          customer: payment_method.customer_id,
          payment_method: payment_method.remote_id,
          confirm: true,
          capture_method: 'automatic_async',
          off_session: true,
          metadata:,
          expand: ['latest_charge'],
        }

        case request_three_d_secure
        when StripeRecord::Request3DS::Any, StripeRecord::Request3DS::Automatic, StripeRecord::Request3DS::Challenge
          self.add_three_d_secure_params(params, request_three_d_secure:, tenant:)
        when StripeRecord::Request3DS::None
          # none
        else
          T.absurd(request_three_d_secure)
        end

        result = StripeRecord::Client::PaymentIntent.create(params, stripe_account_id: tenant_stripe_account.stripe_account_id_if_needed, api_key:)

        T.assert_type!(result, Mangrove::Result[Stripe::PaymentIntent, Stripe::StripeError])

        return Mangrove::Result.err(result.err_inner) if result.is_a?(Mangrove::Result::Err)

        stripe_payment_intent = self.construct_from_remote(user:, remote_payment_intent: result.ok_inner)
        stripe_payment_intent.api_key_account = tenant_stripe_account.api_key_account
        stripe_payment_intent.save!
        Mangrove::Result.ok(stripe_payment_intent)
      end

      # Connect を利用した決済
      sig {
        params(
          tenant_stripe_account: Tenant::StripeAccount, # Connect されている側のアカウント
          charge_type: Tenant::StripeAccount::ChargeTypeEnum,
          fee_rate: BigDecimal,
          payment_method: StripeRecord::PaymentMethod,
          amount: Integer,
          currency: AuthPlatform::Currency,
          user: User,
          request_three_d_secure: StripeRecord::Request3DS,
          metadata: T::Hash[T.untyped, T.untyped],
        ).returns(Mangrove::Result[StripeRecord::PaymentIntent, Stripe::StripeError])
      }
      def api_create_connect_payment_intent(tenant_stripe_account:, charge_type:, fee_rate:, payment_method:, amount:, currency:, user:, request_three_d_secure:, metadata: {})
        tenant = T.must(tenant_stripe_account.tenant)
        stripe_account = T.must(tenant_stripe_account.stripe_account)
        controlling_platform = T.must(stripe_account.controlling_platform)
        api_key = T.must(controlling_platform.api_key)

        # 手数料は四捨五入する
        fee_amount = T.let((amount * fee_rate).round, Integer)

        params = {
          amount:,
          currency: currency.serialize,
          customer: payment_method.customer_id,
          payment_method: payment_method.remote_id,
          confirm: true,
          capture_method: 'automatic_async',
          off_session: T.let(true, T::Boolean),
          metadata:,
          expand: ['latest_charge'],
        }

        case request_three_d_secure
        when StripeRecord::Request3DS::Any, StripeRecord::Request3DS::Automatic, StripeRecord::Request3DS::Challenge
          self.add_three_d_secure_params(params, request_three_d_secure:, tenant:)
        when StripeRecord::Request3DS::None
          # none
        else
          T.absurd(request_three_d_secure)
        end

        result = case charge_type
        when Tenant::StripeAccount::ChargeTypeEnum::DirectCharges
          # ダイレクト支払い
          # 店子はさらに Stripe の決済手数料を支払う（amount - fee_amount - [Stripe 手数料] が店子アカウントの純売上となる）
          StripeRecord::Client::PaymentIntent.create(
            params.merge(
              application_fee_amount: fee_amount,
            ),
            stripe_account_id: stripe_account.remote_id,
            api_key:,
          )
        when Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesApplicationFee
          # デスティネーション支払い（全額を店子アカウントに送金後に手数料を即時回収する）
          # 店子アカウントは Stripe への決済手数料を支払わない（amount - fee_amount 全額が店子アカウントの純売上となる）
          StripeRecord::Client::PaymentIntent.create(
            params.merge(
              application_fee_amount: fee_amount,
              transfer_data: { destination: stripe_account.remote_id },
            ),
            stripe_account_id: nil,
            api_key:,
          )
        when Tenant::StripeAccount::ChargeTypeEnum::DestinationChargesTransfer
          # デスティネーション支払い（手数料を引いた金額を店子アカウントに送金する）
          # 店子アカウントは Stripe への決済手数料を支払わない（amount - fee_amount 全額が店子アカウントの純売上となる）
          StripeRecord::Client::PaymentIntent.create(
            params.merge(
              transfer_data: { amount: (amount - fee_amount), destination: stripe_account.remote_id },
            ),
            stripe_account_id: nil,
            api_key:,
          )
        else
          T.absurd(charge_type)
        end

        T.assert_type!(result, Mangrove::Result[Stripe::PaymentIntent, Stripe::StripeError])

        return Mangrove::Result.err(result.err_inner) if result.is_a?(Mangrove::Result::Err)

        stripe_payment_intent = self.construct_from_remote(user:, remote_payment_intent: result.ok_inner)
        stripe_payment_intent.api_key_account = controlling_platform
        stripe_payment_intent.connect_account = stripe_account
        stripe_payment_intent.charge_type = charge_type.serialize
        # TODO: FIX latest_chargeはsubscriptionがある都合上、一つに定まらないので廃止予定。要修正
        # remote_latest_charge = T.let(result.ok_inner.try(:latest_charge), T.nilable(Stripe::Charge))
        # if remote_latest_charge.present?
        #   latest_charge = stripe_payment_intent.latest_charge || stripe_payment_intent.build_latest_charge(user: T.must(stripe_payment_intent.user), remote_id: remote_latest_charge.id)
        #   latest_charge.api_key_account = stripe_payment_intent.api_key_account
        #   latest_charge.connect_account = stripe_payment_intent.connect_account
        #   latest_charge.charge_type     = stripe_payment_intent.charge_type
        #   latest_charge.assign_remote_attributes(remote_latest_charge)
        # end
        stripe_payment_intent.save!
        Mangrove::Result.ok(stripe_payment_intent)
      end

      sig { params(user: User, remote_payment_intent: Stripe::PaymentIntent).returns(StripeRecord::PaymentIntent) }
      def construct_from_remote(user:, remote_payment_intent:)
        payment_intent = self.new(
          remote_id: remote_payment_intent.id,
          user:,
          tenant_id: user.tenant_id,
        )
        payment_intent.assign_remote_attributes(remote_payment_intent)

        payment_intent
      end

      private

      sig {
        params(
          params: T::Hash[Symbol, T.untyped],
          request_three_d_secure: StripeRecord::Request3DS,
          tenant: Tenant,
        ).void
      }
      def add_three_d_secure_params(params, request_three_d_secure:, tenant:)
        return if request_three_d_secure == StripeRecord::Request3DS::None

        # TODO: Stripe買い切り決済導入時にここのS3セキュアについて要修正
        domain = T.unsafe(tenant).user_page_domain

        params.merge!(
          {
            off_session: false,
            confirm: true,
            confirmation_method: 'automatic',
            capture_method: 'manual',
            return_url: "https://#{domain}/redirect/three-d-secure",
            payment_method_options: {
              card: {
                request_three_d_secure: request_three_d_secure.serialize,
              },
            },
          },
        )
      end
    end

    sig { params(auto_save: T::Boolean).returns(Mangrove::Result[StripeRecord::PaymentIntent, Stripe::StripeError]) }
    def api_refresh(auto_save: true)
      account = T.must(self.api_key_account)
      api_key = account.api_key
      result = StripeRecord::Client::PaymentIntent.retrieve(remote_id, expand: ['latest_charge'], stripe_account_id: self.stripe_account_id_if_needed, api_key:)

      if result.is_a?(Mangrove::Result::Err)
        return Mangrove::Result.err(result.err_inner)
      end

      T.assert_type!(result, Mangrove::Result[Stripe::PaymentIntent, Stripe::StripeError])

      self.assign_remote_attributes(result.ok_inner)
      remote_latest_charge = T.let(result.ok_inner.try(:latest_charge), T.nilable(Stripe::Charge))
      if remote_latest_charge.present?
        latest_charge = self.latest_charge || self.build_latest_charge(user: T.must(self.user), remote_id: remote_latest_charge.id)
        latest_charge.assign_remote_attributes(remote_latest_charge)
        latest_charge.tenant_id = self.tenant_id
        latest_charge.user_id = self.user_id
        latest_charge.payment_intent = self
        latest_charge.api_key_account = self.api_key_account # nilable (only Connect)
        # TODO: StripeConnect対応
        # latest_charge.connect_account = self.connect_account # nilable (only Connect)
      end
      if auto_save
        latest_charge&.save!
        self.save!
      end

      Mangrove::Result.ok(self)
    end

    sig { returns(Mangrove::Result[Stripe::PaymentIntent, Stripe::StripeError]) }
    def capture
      account = T.must(self.api_key_account)
      api_key = T.must(account.api_key)
      result = StripeRecord::Client::PaymentIntent.capture(self.remote_id, api_key:, stripe_account_id: self.stripe_account_id_if_needed)

      if result.is_a?(Mangrove::Result::Ok)
        self.assign_remote_attributes(result.ok_inner)
        self.save!
      end

      result
    end

    sig { returns(Mangrove::Result[Stripe::PaymentIntent, Stripe::StripeError]) }
    def cancel
      account = T.must(self.api_key_account)
      api_key = T.must(account.api_key)
      result = StripeRecord::Client::PaymentIntent.cancel(self.remote_id, api_key:, stripe_account_id: self.stripe_account_id_if_needed)

      if result.is_a?(Mangrove::Result::Ok)
        self.assign_remote_attributes(result.ok_inner)
        self.save!
      end

      result
    end

    sig { params(remote_payment_intent: Stripe::PaymentIntent).returns(StripeRecord::PaymentIntent) }
    def assign_remote_attributes(remote_payment_intent)
      self.amount = remote_payment_intent.amount
      self.currency = remote_payment_intent.currency
      self.status = remote_payment_intent.status
      self.customer_id = remote_payment_intent.customer
      self.payment_method_id = remote_payment_intent.payment_method
      self.payment_method_configuration_details = remote_payment_intent.payment_method_configuration_details.as_json
      self.payment_method_options = remote_payment_intent.payment_method_options.as_json
      self.cancellation_reason = remote_payment_intent.cancellation_reason
      self.description = remote_payment_intent.description
      self.metadata = remote_payment_intent.metadata.as_json
      self.next_action = remote_payment_intent.next_action.as_json
      self.on_behalf_of_id = remote_payment_intent.on_behalf_of
      self.application_fee_amount = remote_payment_intent.application_fee_amount
      self.transfer_data = remote_payment_intent.transfer_data.as_json
      self.transfer_group = remote_payment_intent.transfer_group
      self.created = remote_payment_intent.created
      remote_canceled_at = remote_payment_intent.canceled_at
      self.canceled_at = Time.zone.at(remote_canceled_at) if remote_canceled_at.present?
      self.created_at = Time.zone.at(remote_payment_intent.created)

      self
    end

    sig { returns(T.nilable(String)) }
    def next_action_url_if_available
      # requires_action 以外では url が必要ないので DB にあっても返さない
      return if self.status != StripeRecord::PaymentIntent::StatusEnum::RequiresAction

      next_action = T.let(self.next_action, T.nilable(T::Hash[String, T.untyped]))
      next_action&.dig('redirect_to_url', 'url')
    end
  end
end
