# typed: false

RSpec.describe '[ Logout API ]' do
  describe 'POST /api/v1/authentication/logout' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    before do
      user_1
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

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:session_clear)
      end
    end
  end
end
