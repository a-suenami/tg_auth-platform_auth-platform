# typed: false

RSpec.describe '[ Password API ]' do
  describe 'GET /api/v1/internal/me' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil, email_verified: true)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      before do
        allow(session_mock).to receive(:[]) do |key|
          case key
          when :current_user_id
            user_1.id
          when :current_user_id_expired_at
            1.week.from_now
          end
        end
      end

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['id']).to eq(user_1.id)
        expect(body_hash['email']).to eq(user_1.email)
        expect(body_hash['enabled']).to be(true)
        expect(body_hash['email_verified']).to be(true)
      end
    end
  end
end
