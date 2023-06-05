# typed: false

RSpec.describe '[ email change API ]' do
  describe 'POST /api/v1/internal/email_change/request' do
    let(:user_1) {
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
      user_1
      email_template
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        delivery_id: 1,
      })
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
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

    context 'when email vaild' do
      let(:params) {
        {
          email: 'change-email@example.com',
        }
      }

      it 'returns 204' do
        is_expected.to eq 204
        expect(blastengine_mock).to have_received(:send_email)
        expect(Users::EmailVerifier.find_by(user_id: user_1.id, email_verifier_type: :email_change, email: 'change-email@example.com').email).to eq('change-email@example.com')
      end
    end
  end

  describe 'POST /api/v1/internal/email_change' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', email_verified: false)
    }

    let(:users__email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: user_1, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, email_verifier_type: :email_change,
email: 'change-email@example.com',)
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      users__email_verifier
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when code invaild' do
      let(:params) {
        {
          email_verification_code: '111111',
          user_id: user_1.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(Users::EmailVerifier.find(users__email_verifier.id).remaining_attempts).to be 4
      end
    end

    context 'when remaining_attempts is 0' do
      let(:users__email_verifier) {
        create(:users__email_verifier, tenant_id: current_tenant.id, user: user_1, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 0, email_verifier_type: :email_change,
email: 'change-email@example.com',)
      }
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: user_1.id,
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when code vaild' do
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: user_1.id,
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
        expect(User.find(user_1.id).email).to eq 'change-email@example.com'
      end
    end
  end
end
