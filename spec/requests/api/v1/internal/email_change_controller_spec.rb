# typed: false

RSpec.describe '[ email change API ]' do
  describe 'POST /api/v1/internal/email_change/request' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'test-user1password')
    }

    let(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: 'email_address_change',
        subject: 'email確認のお願い',
        body: <<~TEXT,
          <p>認証コードは以下です</p>
          <p>{{ email_verification_code }}</p>
        TEXT
      )
    }
    let(:blastengine_mock) {
      instance_double(Blastengine::API)
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      current_user
      email_template
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        delivery_id: 1,
      })
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(current_user.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when email vaild' do
      let(:params) {
        {
          email: 'change-email@example.com',
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
        expect(blastengine_mock).to have_received(:send_email)
        expect(Users::EmailVerifier.find_by(user_id: current_user.id, email_verifier_type: :email_change, email: 'change-email@example.com').email).to eq('change-email@example.com')
      end
    end

    context 'when duplicate email with other user' do
      let(:other_user) {
        create(:user, tenant_id: current_tenant.id, email: 'change-email@example.com', password: 'test-user1password')
      }
      let(:params) {
        {
          email: 'change-email@example.com',
        }
      }

      before do
        other_user
      end

      # 重複していても存在確認に利用されないように、エラーは返さないしメールも送る
      it 'returns 204' do
        is_expected.to eq 204
        expect(blastengine_mock).to have_received(:send_email)
        expect(Users::EmailVerifier.find_by(user_id: current_user.id, email_verifier_type: :email_change, email: 'change-email@example.com').email).to eq('change-email@example.com')
      end
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
  end

  describe 'POST /api/v1/internal/email_change' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', email_verified: false)
    }
    let(:other_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-other-user1@example.com', email_verified: false)
    }

    let(:email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, email_verifier_type: :email_change,
email: 'change-email@example.com',)
    }
    let(:other_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '654321', expired_at: 1.hour.from_now, remaining_attempts: 5, email_verifier_type: :email_change,
email: 'change-email@example.com',)
    }
    let(:other_type_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '654321', expired_at: 1.hour.from_now, remaining_attempts: 5, email_verifier_type: :registration,
email: 'change-email@example.com',)
    }
    let(:other_user_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: other_user, code: '111111', expired_at: 1.hour.from_now, remaining_attempts: 5,  email_verifier_type: :email_change,
email: 'change-email@example.com',)
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      current_user
      email_verifier
      other_email_verifier
      other_type_email_verifier
      other_user_email_verifier
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(current_user.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when code vaild' do
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
        expect(User.find(current_user.id).email).to eq 'change-email@example.com'
      end
    end

    context 'when duplicate email with other user' do
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }
      let(:other_user) {
        create(:user, tenant_id: current_tenant.id, email: 'change-email@example.com', password: 'test-user1password')
      }

      before do
        other_user
      end

      it 'returns 400' do
        is_expected.to eq 400
        expect(User.find(current_user.id).email).to eq 'test-user1@example.com'
      end
    end


    context 'when code invaild' do
      let(:params) {
        {
          email_verification_code: '111111',
          user_id: current_user.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(Users::EmailVerifier.find(email_verifier.id).remaining_attempts).to be 4
        expect(Users::EmailVerifier.find(other_email_verifier.id).remaining_attempts).to be 4
        expect(Users::EmailVerifier.find(other_type_email_verifier.id).remaining_attempts).to be 5
        expect(Users::EmailVerifier.find(other_user_email_verifier.id).remaining_attempts).to be 5
      end
    end

    context 'when code expired' do
      let(:email_verifier) {
        create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.ago, remaining_attempts: 5, email_verifier_type: :email_change,
email: 'change-email@example.com',)
      }
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when remaining_attempts is 0' do
      let(:email_verifier) {
        create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 0, email_verifier_type: :email_change,
email: 'change-email@example.com',)
      }
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when code has already been used' do
      let(:email_verifier) {
        create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, used_at: 1.hour.ago,
email_verifier_type: :email_change, email: 'change-email@example.com',)
      }
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end
  end
end
