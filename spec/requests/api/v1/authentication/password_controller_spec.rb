# typed: false

RSpec.describe '[ Password API ]' do
  describe 'POST /api/v1/authentication/passwords' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    before do
      user_1
    end

    context 'when no session' do
      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when password already seted' do
      let(:user_1) {
        create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'This_is_past_password1234')
      }

      let(:session_mock) {
        instance_double(ActionDispatch::Request::Session)
      }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
        allow(session_mock).to receive(:[]).and_return(user_1.id)
        allow(session_mock).to receive(:key?).and_return(false)
        allow(session_mock).to receive(:loaded?).and_return(false)
        allow(session_mock).to receive(:enabled?).and_return(true)
        allow(session_mock).to receive("[]=").and_return(nil)
      end

      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
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
        allow(session_mock).to receive("[]=").and_return(nil)
      end

      let(:params) {
        {
          user: {
            password: 'This_is_password1234',
          },
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
      end
    end
  end
end
