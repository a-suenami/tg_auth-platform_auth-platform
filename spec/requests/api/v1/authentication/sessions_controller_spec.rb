# typed: false

RSpec.describe '[ Sessions API ]' do
  describe 'POST /api/v1/authentication/sessions' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    before do
      user_1
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
          password: 'Password1234!',
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
          password: 'Password1234!',
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
      end
    end
  end
end
