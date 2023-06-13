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
      let(:session_mock) {
        instance_double(ActionDispatch::Request::Session)
      }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
        allow(session_mock).to receive(:[]).and_return(user_1.id)
        allow(session_mock).to receive(:key?).and_return(false)
        allow(session_mock).to receive(:loaded?).and_return(false)
        allow(session_mock).to receive(:enabled?).and_return(true)
        allow(session_mock).to receive(:[]=).and_return(nil)
      end

      it 'returns 204' do
        is_expected.to eq 204
        expect(session_mock).to have_received(:[]=)
      end
    end
  end
end
