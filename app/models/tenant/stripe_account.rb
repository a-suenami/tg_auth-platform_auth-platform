# typed: strict

# ==============================================================================
# app/models/tenant/stripe_account.rb
# ==============================================================================
class Tenant::StripeAccount < ApplicationRecord
  belongs_to :tenant
  belongs_to :stripe_account, class_name: 'StripeRecord::Account'

  # Connect の支払いタイプ
  class ChargeTypeEnum < T::Enum
    enums do
      # Direct charges
      DirectCharges = new('direct_charges')
      # Destination charges
      DestinationChargesApplicationFee = new('destination_charges_application_fee') # 一度全額店子のアカウントに入金してから手数料を回収する
      DestinationChargesTransfer       = new('destination_charges_transfer')        # 手数料を引いた金額を店子アカウントに入金する
    end
  end

  # nilable で、nil のときは Connect を利用しない通常の決済となる
  # Connect を利用するときだけ設定する
  enumerize :charge_type, enum_class: ChargeTypeEnum

  before_validation :set_charge_type

  validates :tenant_id, uniqueness: true
  validates :charge_type, :gacha_check_out_fee_rate, :gacha_shipment_fee_rate,
    presence: true, if: -> { T.cast(self, Tenant::StripeAccount).stripe_account&.connect_account? }
  validates :gacha_check_out_fee_rate, :gacha_shipment_fee_rate, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, allow_nil: true

  sig { returns(T.nilable(BigDecimal)) }
  def gacha_check_out_fee_rate_percentage
    gacha_check_out_fee_rate&.*(100)
  end

  sig { params(percentage: T.nilable(T.any(BigDecimal, String))).returns(T.nilable(BigDecimal)) }
  def gacha_check_out_fee_rate_percentage=(percentage)
    percentage = percentage.to_d if percentage.is_a?(String)
    self.gacha_check_out_fee_rate = percentage&./(100)
  end

  sig { returns(T.nilable(BigDecimal)) }
  def gacha_shipment_fee_rate_percentage
    gacha_shipment_fee_rate&.*(100)
  end

  sig { params(percentage: T.nilable(T.any(BigDecimal, String))).returns(T.nilable(BigDecimal)) }
  def gacha_shipment_fee_rate_percentage=(percentage)
    percentage = percentage.to_d if percentage.is_a?(String)
    self.gacha_shipment_fee_rate = percentage&./(100)
  end

  sig { returns(T.nilable(String)) }
  # ダイレクト支払いの場合は stripe_account として Connect 側のアカウントの ID を送信する必要があるので、その必要がある場合だけ String を返す
  # それ以外の場合は nil を返すので { stripe_account: nil } として request を飛ばせばよい
  def stripe_account_id_if_needed
    return nil unless self.stripe_account&.connect_account?

    # Connected アカウントの場合は必要に応じて stripe_account に渡す account id を返す
    charge_type = T.must(self.charge_type)
    self.stripe_account&.stripe_account_id_if_needed(charge_type: charge_type.enum)
  end

  sig { returns(StripeRecord::Account) }
  def api_key_account
    return T.must(@api_key_account) if defined?(@api_key_account)

    self.load_associations

    stripe_account = T.must(self.stripe_account)

    _api_key_account = if stripe_account.connect_account?
      T.must(stripe_account.controlling_platform)
    else
      stripe_account
    end

    @api_key_account = T.let(_api_key_account, T.nilable(StripeRecord::Account))
    T.must(@api_key_account)
  end

  sig { returns(StripeRecord::APIKey) }
  def api_key
    return T.must(@api_key) if defined?(@api_key)

    @api_key = T.let(api_key_account.api_key, T.nilable(StripeRecord::APIKey))
    T.must(@api_key)
  end

  private

  sig { void }
  def set_charge_type
    self.charge_type = nil unless stripe_account&.connect_account?
  end

  sig { void }
  # self.stripe_account 以降の association にアクセスする際には query の発行数を抑えるために事前に load_associations を呼ぶこと
  def load_associations
    return if self.association(:stripe_account).loaded?

    stripe_account = StripeRecord::Account.eager_load(:api_key, [controlling_platform: :api_key]).find(self.stripe_account_id)
    T.assert_type!(stripe_account, StripeRecord::Account)

    stripe_account_association = T.let(self.association(:stripe_account), ActiveRecord::Associations::BelongsToAssociation)
    stripe_account_association.target = stripe_account
    stripe_account_association.loaded!
  end
end
