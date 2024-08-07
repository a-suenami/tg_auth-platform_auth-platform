# typed: strict

module AuthPlatform
  class ShippingAddressParams < T::Struct
    const :name,          String
    const :name_furigana, T.nilable(String)
    const :phone_number,  String
    const :email,         String
    const :country_code,  String
    const :postal_code,   String
    const :region_code,   String
    const :municipality,  String
    const :street,        String
    const :building,      T.nilable(String)
  end

  class PaymentProviderEnum < T::Enum
    enums do
      Payjp  = new('payjp')
      Stripe = new('stripe')
    end
  end

  class Currency < T::Enum
    # Stripe の仕様では API request 時にすべて小文字で指定する必要があるため、それに合わせて serialized value は小文字で定義する
    # また通過自体は3文字の ISO コードで表現する
    enums do
      JPY = new('jpy')
    end
  end

  PaymentableClasses = T.type_alias { T.any(PayjpPayment, KomojuPayment, Gacha::Coupon, StripeRecord::PaymentIntent, NullPayment) }
end
