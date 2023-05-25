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
end
