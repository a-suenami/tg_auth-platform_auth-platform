# typed: false

RSpec.describe '[ Logout API ]' do
  describe 'POST /api/v1/authentication/logout' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    before do
      current_user
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:session_clear)
      end
    end
  end
end
