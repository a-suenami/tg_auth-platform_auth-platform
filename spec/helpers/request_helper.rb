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

  shared_context 'current user session is present' do
    let(:session_mock) {
      instance_double(ExpirableCookie)
    }

    before do
      allow(ExpirableCookie).to receive(:new).and_return(session_mock)
      allow(session_mock).to receive(:[]=).and_return(nil)
      allow(session_mock).to receive(:session_clear).and_return(nil)
      allow(session_mock).to receive(:[]) do |key|
        case key
        when :current_user_id
          current_user.id
        when :current_user_id_expired_at
          1.week.from_now
        end
      end
    end
  end
end
