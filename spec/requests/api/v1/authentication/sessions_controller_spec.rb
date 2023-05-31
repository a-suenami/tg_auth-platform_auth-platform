# typed: false

RSpec.describe '[ Sessions API ]' do
  describe 'POST /api/v1/authentication/sessions' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'test-user1password')
    }

    before do
      user_1
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
          password: 'test-user1password',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when password invaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'test-d',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'test-user1password',
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
      end
    end
  end

  describe 'POST /api/v1/authentication/sessions/logout' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'test-user1password')
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    it 'returns 200' do
      is_expected.to eq 200
      expect(session_mock).to have_received(:[]=)
    end
  end
end
