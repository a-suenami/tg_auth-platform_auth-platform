# typed: false

RSpec.describe '[ Registrations API ]' do
  describe 'POST /api/v1/authentication/registrations/send_verification_email' do

    let(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: 'email_address_verification',
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

    before do
      email_template
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        delivery_id: 1,
      })
    end

    context 'when params vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
        }
      }

      context 'when first time registration' do
        it 'returns 200' do
          is_expected.to eq 200
          expect(blastengine_mock).to have_received(:send_email)
        end
      end

      context 'when user already exists and email_verified is false' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: false)
        }

        before do
          current_user
        end

        it 'returns 200' do
          is_expected.to eq 200
          expect(blastengine_mock).to have_received(:send_email)
        end
      end

      context 'when user already exists and enabled is false' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: false)
        }

        before do
          current_user
        end

        it 'returns 200' do
          is_expected.to eq 200
          expect(blastengine_mock).to have_received(:send_email)
        end
      end


      context 'when user already exists and enabled is true' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: true)
        }

        before do
          current_user
        end

        it 'returns 200' do
          is_expected.to eq 200
          expect(blastengine_mock).to have_received(:send_email)
        end
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

  describe 'POST /api/v1/authentication/registrations/verify_email' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', email_verified: false, enabled: false)
    }
    let(:other_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-other-user1@example.com', email_verified: false)
    }

    let(:email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, verifier_type: :registration)
    }
    let(:other_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '654321', expired_at: 1.hour.from_now, remaining_attempts: 5, verifier_type: :registration)
    }
    let(:other_type_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '654321', expired_at: 1.hour.from_now, remaining_attempts: 5, verifier_type: :email_change)
    }
    let(:other_user_email_verifier) {
      create(:users__email_verifier, tenant_id: current_tenant.id, user: other_user, code: '111111', expired_at: 1.hour.from_now, remaining_attempts: 5,  verifier_type: :registration)
    }

    before do
      current_user
      other_user
      email_verifier
      other_email_verifier
      other_type_email_verifier
      other_user_email_verifier
    end

    context 'when code vaild' do
      let(:params) {
        {
          email_verification_code: '123456',
          user_id: current_user.id,
        }
      }

      context 'when unregistered user' do
        it 'returns 200' do
          is_expected.to eq 200
          expect(User.find(current_user.id).email_verified).to be true
          expect(Users::EmailVerifier.find(email_verifier.id).used_at).not_to be_nil
          expect(body_hash['user_id']).to eq(current_user.id)
          expect(body_hash['email_verified']).to be true
          expect(body_hash['registered']).to be false
        end
      end

      context 'when registered user' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', email_verified: true, enabled: true)
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(User.find(current_user.id).email_verified).to be true
          expect(Users::EmailVerifier.find(email_verifier.id).used_at).not_to be_nil
          expect(body_hash['user_id']).to eq(current_user.id)
          expect(body_hash['email_verified']).to be true
          expect(body_hash['registered']).to be true
        end
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
        create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.ago, remaining_attempts: 5, verifier_type: :registration)
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
        create(:users__email_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 0, verifier_type: :registration)
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
verifier_type: :registration,)
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
