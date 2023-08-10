# typed: false

RSpec.describe '[ Sessions API ]' do
  describe 'POST /api/v1/authentication/sessions' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    before do
      current_user
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
          password: 'Password1234!',
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when the user with the specified email does not exist' do
      let(:params) {
        {
          email: 'unknownuser@example.com',
          password: 'Password1234!',
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
        expect(AccountLock.find_by(email: 'unknownuser@example.com').failed_attempts).to be 1
      end
    end

    context 'when password invaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'test-d',
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
        expect(AccountLock.find_by(email: 'test-user1@example.com').failed_attempts).to be 1
      end
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'Password1234!',
        }
      }

      context 'when set_parent_domain_cookie is true' do
        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['id']).to eq(current_user.id)
          expect(response.get_header('Set-Cookie').match(/domain=([^;]+)/)[1]).to eq 'localhost.com'
        end
      end

      context 'when set_parent_domain_cookie is false' do
        let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', set_parent_domain_cookie: false) }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['id']).to eq(current_user.id)
          # ドメインが指定されない状態が最も安全なので、ドメイン指定がないことを確認する
          expect(response.get_header('Set-Cookie').match(/domain=([^;]+)/)).to be_nil
        end
      end
    end

    context 'when the user is locked' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          user_id: user_1.id,
          email: 'test-user1@example.com',
          failed_attempts: 10,
          unlock_token: SecureRandom.hex(32),
          lock_expired_at: 1.minute.from_now,
          last_failed_at: Time.zone.now,)
      }

      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'Password1234!',
        }
      }

      before do
        account_lock
      end

      it 'returns 400' do
        is_expected.to eq 400
        expect(body_hash['error']['code']).to eq 'account_locked'
      end
    end

    context 'when account lock is expired' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          user_id: user_1.id,
          email: 'test-user1@example.com',
          failed_attempts: 10,
          unlock_token: SecureRandom.hex(32),
          lock_expired_at: 1.minute.ago,
          last_failed_at: Time.zone.now,)
      }

      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'Password1234!',
        }
      }

      before do
        account_lock
      end

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['id']).to eq(user_1.id)
        expect(AccountLock.find_by(email: 'test-user1@example.com').failed_attempts).to be 0
      end
    end

    context 'when enough time has passed from last_failed_at' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          user_id: user_1.id,
          email: 'test-user1@example.com',
          failed_attempts: 5,
          unlock_token: nil,
          lock_expired_at: nil,
          last_failed_at: 30.minutes.ago,)
      }

      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'hogehoge',
        }
      }

      before do
        account_lock
      end

      it 'returns 401' do
        is_expected.to eq 401
        expect(AccountLock.find_by(email: 'test-user1@example.com').failed_attempts).to be 1
      end
    end

    context 'when user has deleted' do
      let(:user_1) {
        create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', deleted: true)
      }

      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'Password1234!',
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end
  end
end
