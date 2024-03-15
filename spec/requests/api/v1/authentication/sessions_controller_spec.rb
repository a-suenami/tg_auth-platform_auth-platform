# typed: false

RSpec.describe '[ Sessions API ]' do
  describe 'POST /api/v1/authentication/sessions' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', suppress_sms_verification:)
    }
    let(:deleted_user) {
      create(:user, :skip_validate, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: true, deleted: true)
    }
    let(:suppress_sms_verification) { false }

    let(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: 'account_lock',
        subject: 'アカウントロック メール',
        body: <<~TEXT,
          <p>アカウントロックを解除するには以下のリンクをクリックしてください</p>
          <p>{{ unlock_url }}</p>
        TEXT
      )
    }

    let(:blastengine_mock) {
      instance_double(Blastengine::API)
    }

    before do
      email_template
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        delivery_id: 1,
      })
      current_user
      deleted_user
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

      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['id']).to eq(current_user.id)
        expect(body_hash['suppress_sms_verification']).to be(false)
      end
    end

    context 'when user.suppress_sms_verification is true' do
      let(:suppress_sms_verification) { true }
      let(:params) {
        {
          email: 'test-user1@example.com',
          password: 'Password1234!',
        }
      }

      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['id']).to eq(current_user.id)
        expect(body_hash['suppress_sms_verification']).to be(true)
      end
    end

    context 'when failed_attempts exceeds 10' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          email: 'test-user1@example.com',
          failed_attempts: 9,
          unlock_token: nil,
          lock_expired_at: nil,
          last_failed_at: Time.zone.now,)
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
        expect(body_hash['error']['code']).to eq 'invalid_request'
        expect(AccountLock.find_by(email: 'test-user1@example.com').failed_attempts).to be 10
        expect(AccountLock.find_by(email: 'test-user1@example.com').locked?).to be true
        expect(blastengine_mock).to have_received(:send_email)
      end
    end

    context 'when failed_attempts exceeds 10 and active user not presented' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
          email: 'unknown_user@example.com',
          failed_attempts: 9,
          unlock_token: nil,
          lock_expired_at: nil,
          last_failed_at: Time.zone.now,)
      }
      let(:params) {
        {
          email: 'unknown_user@example.com',
          password: 'hogehoge',
        }
      }

      before do
        account_lock
      end

      it 'returns 401' do
        is_expected.to eq 401
        expect(body_hash['error']['code']).to eq 'invalid_request'
        expect(AccountLock.find_by(email: 'unknown_user@example.com').failed_attempts).to be 10
        expect(AccountLock.find_by(email: 'unknown_user@example.com').locked?).to be true
        expect(blastengine_mock).not_to have_received(:send_email)
      end
    end



    context 'when the user is locked' do
      let(:account_lock) {
        create(:account_lock,
          tenant_id: current_tenant.id,
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
