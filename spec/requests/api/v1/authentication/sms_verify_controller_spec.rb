# typed: false

RSpec.describe '[ SmsVerify API ]' do
  describe 'POST /api/v1/authentication/sms_verify/send_verification_sms' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }
    let(:sms_verification_required) { true }

    let(:sms_link_mock) {
      instance_double(SmsLink::API)
    }

    let(:twilio_mock) {
      instance_double(Twilio::API)
    }

    before do
      current_user
      allow(SmsLink::API).to receive(:new).and_return(sms_link_mock)
      allow(sms_link_mock).to receive(:send_sms).and_return({
        delivery_id: '1f6ad576fbf9902bc4705296e9dc84c5',
        accepted_at: '2023-12-05T21:10:26+09:00',
        reserved_at: '2023-12-05T21:10:26+09:00',
        contacts: [
          {
            contact_id: 8_846_450,
            phone_number: '08095863896',
            result_code: 'RST200001',
            result_message: '配信対象に登録しました。',
          },
        ],
        click_count_urls: [],
      })
      allow(Twilio::API).to receive(:new).and_return(twilio_mock)
      twilio_respo = Struct.new(:sid).new('SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
      allow(twilio_mock).to receive(:send_sms).and_return(twilio_respo)
    end

    context 'when no session' do
      let(:params) {
        {
          phone_number: '08012345678',
          phone_country_code: '81',
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      let(:session_mock) {
        instance_double(ExpirableCookie)
      }

      before do
        allow(ExpirableCookie).to receive(:new).and_return(session_mock)
        allow(session_mock).to receive(:[]=).and_return(nil)
        allow(session_mock).to receive(:session_clear).and_return(nil)
        allow(session_mock).to receive(:[]) do |key|
          case key
          when :current_user_id, :current_user_id_expired_at
            nil
          when :registering_user_id
            current_user.id
          when :registering_user_id_expired_at
            1.week.from_now
          end
        end
      end

      context 'when sms_verification_required is false' do
        let(:sms_verification_required) { false }

        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        it 'returns 200' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'sms_verification_disabled'
        end
      end

      context 'when given a japan phone number' do
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(sms_link_mock).to have_received(:send_sms)
          expect(Users::SmsVerifier.find_by(user: current_user).phone_number).to eq '+818012345678'
        end
      end

      context 'when given a oversea phone number' do
        let(:params) {
          {
            phone_number: '3181234567',
            phone_country_code: '1',
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(twilio_mock).to have_received(:send_sms)
          expect(Users::SmsVerifier.find_by(user: current_user).phone_number).to eq '+13181234567'
        end
      end

      context 'when given a invalid phone number' do
        let(:params) {
          {
            phone_number: '112212212121',
            phone_country_code: '1111111',
          }
        }

        it 'returns 200' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'phone_number_invaild'
        end
      end

      context 'when current user has already set up a phone number' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil, phone_number: '+818087654321', sms_verified: true)
        }
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        it 'returns 200' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'phone_number_already_set'
        end
      end

      context 'When a given phone number is already in use by another user' do
        let(:other_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-other-user1@example.com', password_digest: nil, phone_number: '+818012345678', sms_verified: true)
        }
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        before do
          other_user
        end


        it 'returns 200' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'phone_number_duplicated'
        end
      end
    end
  end

  describe 'POST /api/v1/authentication/sms_verify/verify_sms' do
    let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }
    let(:sms_verification_required) { true }

    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', sms_verified: false, enabled: false)
    }
    let(:other_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-other-user1@example.com', sms_verified: false)
    }

    let(:sms_verifier) {
      create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, verifier_type: :registration)
    }
    let(:other_sms_verifier) {
      create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '654321', expired_at: 1.hour.from_now, remaining_attempts: 5, verifier_type: :registration)
    }
    let(:other_user_sms_verifier) {
      create(:users__sms_verifier, tenant_id: current_tenant.id, user: other_user, code: '111111', expired_at: 1.hour.from_now, remaining_attempts: 5,  verifier_type: :registration)
    }

    let(:session_mock) {
      instance_double(ExpirableCookie)
    }

    before do
      current_user
      other_user
      sms_verifier
      other_sms_verifier
      other_user_sms_verifier
      allow(ExpirableCookie).to receive(:new).and_return(session_mock)
      allow(session_mock).to receive(:[]=).and_return(nil)
      allow(session_mock).to receive(:session_clear).and_return(nil)
      allow(session_mock).to receive(:[]) do |key|
        case key
        when :current_user_id, :current_user_id_expired_at
          nil
        when :registering_user_id
          current_user.id
        when :registering_user_id_expired_at
          1.week.from_now
        end
      end
    end

    context 'when sms_verification_required is false' do
      let(:sms_verification_required) { false }

      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      it 'returns 200' do
        is_expected.to eq 400
        expect(body_hash['error']['code']).to eq 'sms_verification_disabled'
      end
    end

    context 'when code vaild' do
      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      context 'when unregistered user' do
        it 'returns 200' do
          is_expected.to eq 200
          expect(User.find(current_user.id).sms_verified).to be true
          expect(Users::SmsVerifier.find(sms_verifier.id).used_at).not_to be_nil
          expect(body_hash['user_id']).to eq(current_user.id)
          expect(body_hash['sms_verified']).to be true
          expect(body_hash['registered']).to be false
        end
      end
    end

    context 'when code invaild' do
      let(:params) {
        {
          sms_verification_code: '111111',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
        expect(Users::SmsVerifier.find(sms_verifier.id).remaining_attempts).to be 4
        expect(Users::SmsVerifier.find(other_sms_verifier.id).remaining_attempts).to be 4
        expect(Users::SmsVerifier.find(other_user_sms_verifier.id).remaining_attempts).to be 5
      end
    end

    context 'when code expired' do
      let(:sms_verifier) {
        create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.ago, remaining_attempts: 5, verifier_type: :registration)
      }
      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when remaining_attempts is 0' do
      let(:sms_verifier) {
        create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 0, verifier_type: :registration)
      }
      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when code has already been used' do
      let(:sms_verifier) {
        create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, used_at: 1.hour.ago,
verifier_type: :registration,)
      }
      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end
  end
end
