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

      context 'when cookie_domain_remove_length is 0' do
        let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 0) }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['id']).to eq(current_user.id)
          set_cookies = response.headers['Set-Cookie'].split("\n")
          expected_cookie = set_cookies.find { |cookie| cookie.match?(/domain=sample.localhost.com/) }

          expect(expected_cookie).to be_present
        end
      end

      context 'when cookie_domain_remove_length is 1' do
        let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 1) }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['id']).to eq(current_user.id)
          set_cookies = response.headers['Set-Cookie'].split("\n")
          expected_cookie = set_cookies.find { |cookie| cookie.match?(/domain=localhost.com/) }

          expect(expected_cookie).to be_present
        end
      end

      # Set-Cookieヘッダーが複数あった場合、最初の一つ以外消されるためテストができない。
      context 'when present old session' do
        let(:headers) {
          cookie_str = <<~STR
            _rails_app_session=R7Sn2dHuJwPakROI1Jsg4hGFv5JvQg5kkUo4qfzjwkK4L8oh9OAzclZNyPEemQI0%2FI36ij5fmQuYgMzf7HwsrFwYIJnmsKi8nf4sNqrjpthzZwo
            7REupVtCR11V6HaVOBd1g1ojQJXMz3xb7wMR8iSYMZojpYXCNJYEIzo67sYCuAn7dVCKOdughXjYGOz%2FHvEG2JW6%2F8DqKWaMv0i7o2y7dH6mUye1gY5hzCIKYxDGwGh4
            q9%2B9CSQuJZCUdtRu7V9bGdLTqd9pkfup2Yd3hNGhkk2prZ5Kp5RQ%2FRrOzddfmNze5Mu9mbxrn2q2VvGH04KPwi9jlAxpuxmKwfRndRwEjZj5AKCEvZtMjCgBRl0k4%2F
            CRiQzdjHMQBFDLcSdzRHN%2FCs%2Blp--iTErSVy1gILZryf3--1j77WX3GdnmMzY4BB%2FkOqw%3D%3D; _rails_app_session=PQax5Hy5P0iQK8%2FOYj%2F8B6s1dy
            uu%2FgfEAZgOlbNgYe%2FSDSGQ796iKYHHnCK2PlcTvUNwVTEyTFO6RF%2BOdyNQkqPY16BJ0dAeN2vzclojc6hIpJW14iNwp%2BE3TYB2wtrn86yj9jW1OgtbCo7oira4yX
            DYLuAgPua5NN3zNvbiPCKKlX7xEFnKAW7Ap1rYIXLAnfPgGmRnFtudLRulDqsKXPQZ9bosamUvmR28s4fWLcOkjPDcyHDLT5ITPEeJrKJJCtMH0yIwpT1%2F8PiqZsn8W9PV
            5K5TEW%2B8QR%2B1nEUxsI67ks57nWeSesQk7uSvQlGBd%2FL5u0k5C%2BhfU88lI7IKcecYi0Yr7U3AXh%2F7uKnQYeW%2FCNDBpAOVAIQ%2FTYbpFTf6lR%2F7Yk94--Yl
            W1s2Ln67RFQm%2Fd--VgEMIsgftCDZwoRY36dprQ%3D%3D
          STR
          {
            'Cookie' => cookie_str.gsub(/\R/, ''),
          }
        }

        context 'when cookie_domain_remove_length is 0' do
          let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 0) }

          it 'returns 200' do
            is_expected.to eq 200
            expect(body_hash['id']).to eq(current_user.id)
            set_cookies = response.headers['Set-Cookie'].split("\n")
            expected_cookie_1 = set_cookies.find { |cookie| cookie.start_with?('_rails_app_session=; domain=localhost.com;') }
            expected_cookie_2 = set_cookies.find { |cookie| cookie.start_with?('_rails_app_session=; domain=com;') }

            expect(expected_cookie_1).to be_present
            expect(expected_cookie_2).to be_present
          end
        end

        context 'when cookie_domain_remove_length is 1' do
          let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', cookie_domain_remove_length: 1) }

          it 'returns 200' do
            is_expected.to eq 200
            expect(body_hash['id']).to eq(current_user.id)
            set_cookies = response.headers['Set-Cookie'].split("\n")
            expected_cookie_1 = set_cookies.find { |cookie| cookie.start_with?('_rails_app_session=; domain=sample.localhost.com;') }
            expected_cookie_2 = set_cookies.find { |cookie| cookie.start_with?('_rails_app_session=; domain=com;') }

            expect(expected_cookie_1).to be_present
            expect(expected_cookie_2).to be_present
          end
        end
      end
    end

    context 'when the user is locked' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          user_id: current_user.id,
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
          user_id: current_user.id,
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
        expect(body_hash['id']).to eq(current_user.id)
        expect(AccountLock.find_by(email: 'test-user1@example.com').failed_attempts).to be 0
      end
    end

    context 'when enough time has passed from last_failed_at' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          user_id: current_user.id,
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
      let(:current_user) {
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
