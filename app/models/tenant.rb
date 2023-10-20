# typed: strict

class Tenant < ApplicationRecord
  extend T::Sig

  validates :id, :name, presence: true
  validates :id, uniqueness: { case_sensitive: false }
  validates :id, format: { with: /\A[a-z0-9][a-z0-9-]+[a-z0-9]\z/ }

  has_one :login_spa_application, dependent: :destroy

  # 万が一設定ミスするとクッキーモンスター問題等で情報漏洩のリスクがあるので、あらかじめ制限をかける。
  validates :cookie_domain_remove_length, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 2 }

  class << self
    extend T::Sig

    sig { returns(T.nilable(String)) }
    def current_id
      RequestStore.store[:current_tenant]&.to_s
    end

    sig { returns(T.nilable(String)) }
    def current_domain
      RequestStore.store[:current_tenant_domain]&.to_s
    end

    sig { returns(T.nilable(Tenant)) }
    def current
      return if self.current_domain.blank?

      # cache がない場合
      if RequestStore.store[:current_tenant_object].blank?
        RequestStore.store[:current_tenant_object] = self.find_by!(domain: self.current_domain)
        RequestStore.store[:current_tenant] = RequestStore.store[:current_tenant_object].id
      end

      # cache と current_domain が違う場合は取得し直す
      if RequestStore.store[:current_tenant_object].domain != self.current_domain
        RequestStore.store[:current_tenant_object] = self.find_by!(domain: self.current_domain)
        RequestStore.store[:current_tenant] = RequestStore.store[:current_tenant_object].id
      end

      RequestStore.store[:current_tenant_object]
    end

    sig { params(id: String).returns(String) }
    def current_domain=(id)
      RequestStore.store[:current_tenant_domain] = id
    end
  end
end
