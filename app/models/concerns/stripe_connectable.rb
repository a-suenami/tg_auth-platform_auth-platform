# typed: strict

# ==============================================================================
# app/models/concerns/stripe_connectable.rb
# ==============================================================================
module StripeConnectable
  extend ActiveSupport::Concern
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ApplicationRecord }

  included do
    T.bind(self, T.class_of(ApplicationRecord))

    # raise '"charge_type" column is required' unless self.column_names.include?('charge_type')

    # Slash Gift 側での管理用
    belongs_to :api_key_account, class_name: 'StripeRecord::Account'
    belongs_to :connect_account, class_name: 'StripeRecord::Account', optional: true

    # Slash Gift 側での管理用
    enumerize :charge_type, enum_class: Tenant::StripeAccount::ChargeTypeEnum
  end

  # ダイレクト支払いの場合は stripe_account として Connect 側のアカウントの ID を送信する必要があるので、その必要がある場合だけ String を返す
  # それ以外の場合は nil を返すので { stripe_account: nil } として request を飛ばせばよい
  sig { returns(T.nilable(String)) }
  def stripe_account_id_if_needed
    self.connect_account&.stripe_account_id_if_needed(charge_type: T.must(self.charge_type).enum)
  end
end
