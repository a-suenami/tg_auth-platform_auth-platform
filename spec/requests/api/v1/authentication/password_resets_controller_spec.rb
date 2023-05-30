# typed: false

RSpec.describe '[ Password Resets API ]' do
  describe 'POST /api/v1/authentication/password_resets/request' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'test-user1password')
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
    let(:blastengine_mock) {
      instance_double(Blastengine::API)
    }

    before do
      user_1
      email_template
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
      it 'returns 200' do
        is_expected.to eq 200
      end
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
      end
    end
  end

  describe 'POST /api/v1/authentication/password_resets' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'test-user1password')
    }
    let(:users_password_resets) {
      create(:users__password_resets, tenant_id: current_tenant.id, user_id: user_1.id, code: 'this_is_code', expired_at: 1.hour.from_now)
    }

    before do
      user_1
      users_password_resets
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
          password_reset_code: 'hogehoge',
          password: 'Abc123456$%',
          password_confirmation: 'Abc123456$%',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when given email not associated with a user' do
      let(:params) {
        {
          email: 'test-email@example.com',
          password_reset_code: 'hogehoge',
          password: 'Abc123456$%',
          password_confirmation: 'Abc123456$%',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when code invaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
          password_reset_code: 'hogehoge',
          password: 'Abc123456$%',
          password_confirmation: 'Abc123456$%',
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
          password_reset_code: 'this_is_code',
          password: 'Abc123456$%',
          password_confirmation: 'Abc123456$%',
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
      end
    end
  end

end
