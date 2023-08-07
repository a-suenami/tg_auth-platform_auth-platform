# typed: false

RSpec.describe '[ Password Resets API ]' do
  describe 'POST /api/v1/authentication/password_resets/request' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!')
    }

    let(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: 'password_reset',
        subject: 'password reset メール',
        body: <<~TEXT,
          <p>以下のURLを開いてパスワードを設定してください</p>
          <p>{{ password_reset_url }}</p>
        TEXT
      )
    }
    let(:login_spa_application) {
      create(:login_spa_application, tenant_id: current_tenant.id)
    }
    let(:blastengine_mock) {
      instance_double(Blastengine::API)
    }

    before do
      current_user
      email_template
      login_spa_application
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        delivery_id: 1,
      })
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when user not found' do
      let(:params) {
        {
          email: 'test-user-not-found@example.com',
        }
      }

      # ユーザの存在確認をされないために200を返す
      it 'returns 204' do
        is_expected.to eq 204
      end
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
      end
    end
  end

  describe 'POST /api/v1/authentication/password_resets' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true)
    }
    let(:users_password_resets) {
      create(:users__password_resets, tenant_id: current_tenant.id, user_id: current_user.id, code: 'this_is_code', expired_at: 1.hour.from_now)
    }
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

    before do
      current_user
      users_password_resets
      account_lock
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
          password_reset_code: 'this_is_code',
          password: 'Abc123456$%',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(user_1.account_lock).to be_locked
      end
    end

    context 'when given email not associated with a user' do
      let(:params) {
        {
          email: 'test-email@example.com',
          password_reset_code: 'this_is_code',
          password: 'Abc123456$%',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(user_1.account_lock).to be_locked
      end
    end

    context 'when code invaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password_reset_code: 'hogehoge',
          password: 'Abc123456$%',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(user_1.account_lock).to be_locked
      end
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password_reset_code: 'this_is_code',
          password: 'Abc123456$%',
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
        expect(Users::PasswordReset.find(users_password_resets.id).used_at).to be_between(1.minute.ago, Time.zone.now)
        expect(current_user.reload.authenticate('Abc123456$%')).to be_truthy
        expect(current_user.account_lock).not_to be_locked
      end
    end

    context 'when params invaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password_reset_code: 'this_is_code',
          password: 'Abc123456',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(user_1.account_lock).to be_locked
      end
    end
  end

end
