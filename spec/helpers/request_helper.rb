# typed: false

# ==============================================================================
# spec - request helpers
# ==============================================================================
module RequestHelpers
  def body_hash
    ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response.body)) if response.body.present?
  end

  def body_array
    JSON.parse(response.body) if response.body.present?
  end


  def self.included(base)
    base.instance_eval do
      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
      let(:current_user) { create(:user, tenant_id: current_tenant.id) }

      before do
        RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
        host! "#{current_tenant.id}.localhost.com"
      end
    end
  end
end
