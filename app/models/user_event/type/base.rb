# typed: strict
# frozen_string_literal: true

class UserEvent::Type::Base
  extend T::Sig
  include ActiveModel::Model
  include ActiveModel::Attributes

  # イベント種別名（クラス名から自動生成: ManuallyTagged -> 'manually_tagged'）
  sig { returns(String) }
  def event_type_name
    self.class.name.demodulize.underscore
  end

  # payload として保存する Hash を返す
  sig { returns(T::Hash[String, T.untyped]) }
  def to_payload
    attributes.compact
  end
end
