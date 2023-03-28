# typed: strict

class Tenant < ApplicationRecord
  extend T::Sig

  validates :id, :name, presence: true
  validates :id, uniqueness: { case_sensitive: false }
  validates :id, format: { with: /\A[a-z0-9][a-z0-9-]+[a-z0-9]\z/ }

  class << self
    extend T::Sig

    sig { returns(T.nilable(String)) }
    def current_id
      RequestStore.store[:current_tenant]&.to_s
    end

    sig { returns(T.nilable(Tenant)) }
    def current
      return if self.current_id.blank?

      # cache がない場合
      if RequestStore.store[:current_tenant_object].blank?
        RequestStore.store[:current_tenant_object] = self.find(self.current_id)
      end

      # cache と current_id が違う場合は取得し直す
      if RequestStore.store[:current_tenant_object].id != self.current_id
        RequestStore.store[:current_tenant_object] = self.find(self.current_id)
      end

      RequestStore.store[:current_tenant_object]
    end

    sig { params(id: String).returns(String) }
    def current_id=(id)
      RequestStore.store[:current_tenant] = id
    end
  end
end
