# typed: false

# ==============================================================================
# spec - request helpers
# ==============================================================================
module RequestHelpers
  def body_hash
    return nil if response.body.blank?

    response_body_hash = JSON.parse(response.body)

    case response_body_hash
    when Hash
      ActiveSupport::HashWithIndifferentAccess.new(response_body_hash)
    when Array
      response_body_hash.map(&:with_indifferent_access)
    else
      response_body_hash
    end
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

  def expect_attributes_in_error_messages(body_hash, expected_attributes)
    # params.messages のキーを取得
    actual_attributes = body_hash['error']['params']['messages'].keys.map(&:strip)

    # 期待する属性がすべて含まれているか確認
    missing_attributes = expected_attributes - actual_attributes

    expect(missing_attributes).to be_empty, "The following attributes are missing in params messages: #{missing_attributes.join(', ')}"
  end
end
