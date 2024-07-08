# typed: false

RSpec.describe '[ Logout API ]' do
  describe 'POST /api/v1/authentication/logout' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }
    let(:deleted_user) {
      create(:user, :skip_validate, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: true, deleted: true,
deleted_at: Time.zone.now,)
    }

    before do
      current_user
      deleted_user
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
