# typed: false

RSpec.describe '[ SmsVerify API ]' do
  describe 'POST /api/v1/authentication/sms_verify/send_verification_sms' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:deleted_user) {
      create(:user, :skip_validate, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: true, phone_number: '+818012345678',
deleted: true, deleted_at: Time.zone.now,)
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
      deleted_user
      allow(SmsLink::API).to receive(:new).and_return(sms_link_mock)
      allow(sms_link_mock).to receive(:send_sms).and_return({
        'verification_code_id' => 34,
        'accepted_at' => '2022-03-02T18:23:24+09:00',
        'phone_number' => '090xxxxxxxx',
        'verification_code' => 'sfas33',
        'delivery_type' => 10,
        'user_reference' => 'sample',
      })
      allow(Twilio::API).to receive(:new).and_return(twilio_mock)
      twilio_respo = Struct.new(:sid).new('SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
      allow(twilio_mock).to receive(:send_sms_with_twilio_verify).and_return(twilio_respo)
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
          when :current_user_id
            current_user.id
          when :current_user_id_expired_at
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
          expect(Users::SmsVerifier.find_by(user: current_user).sms_sid).to eq '34'
        end
      end

      context 'when given a oversea phone number' do
        let(:params) {
          {
            phone_number: '3185555555',
            phone_country_code: '1',
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(twilio_mock).to have_received(:send_sms_with_twilio_verify)
          expect(Users::SmsVerifier.find_by(user: current_user).phone_number).to eq '+13185555555'
          expect(Users::SmsVerifier.find_by(user: current_user).sms_sid).to eq 'SMXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
        end
      end

      context 'when given afghanistan phone number' do
        let(:params) {
          {
            phone_number: '202222222',
            phone_country_code: '93',
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'no_sms_supported_country'
          expect(twilio_mock).not_to have_received(:send_sms_with_twilio_verify)
        end
      end

      context 'when given azerbaijan phone number' do
        let(:params) {
          {
            phone_number: '125555555',
            phone_country_code: '994',
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'no_sms_supported_country'
          expect(twilio_mock).not_to have_received(:send_sms_with_twilio_verify)
        end
      end

      # ロシアとカザフスタンは国際電話番号国コードが同じだが、ロシアのみエラーを返すか確認
      context 'when given russia phone number' do
        let(:params) {
          {
            phone_number: '4951234567',
            phone_country_code: '7',
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'no_sms_supported_country'
          expect(twilio_mock).not_to have_received(:send_sms_with_twilio_verify)
        end
      end

      context 'when given kazakhstan phone number' do
        let(:params) {
          {
            phone_number: '7272517123',
            phone_country_code: '7',
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(twilio_mock).to have_received(:send_sms_with_twilio_verify)
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

      context 'when rate limit by 5/phone_nubmer/3hours' do
        let(:sms_verifiers) {
          create_list(:users__sms_verifier, 5, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 2.hours.from_now, remaining_attempts: 5, verifier_type: :registration,
         phone_number: '+818012345678',)
        }
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        before do
          sms_verifiers
        end

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'sms_send_limit'
        end
      end

      context 'when rate limit by 10/phone_nubmer/24hours' do
        let(:sms_verifiers) {
          create_list(:users__sms_verifier, 10, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 23.hours.from_now, remaining_attempts: 5, verifier_type: :registration,
         phone_number: '+818012345678',)
        }
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        before do
          sms_verifiers
        end

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'sms_send_limit'
        end
      end

      # context 'when rate limit by 100/ip_address/1hours' do
      #   let(:other_user) {
      #     create(:user, tenant_id: current_tenant.id, email: 'test-other-user1@example.com', sms_verified: false)
      #   }
      #   let(:sms_verifiers) {
      #     create_list(:users__sms_verifier, 100, tenant_id: current_tenant.id, user: other_user, code: '123456', expired_at: 59.minutes.from_now, remaining_attempts: 5, verifier_type: :registration,
      #    ip_address: '127.0.0.1',)
      #   }

      #   let(:params) {
      #     {
      #       phone_number: '08012345678',
      #       phone_country_code: '81',
      #     }
      #   }

      #   before do
      #     sms_verifiers
      #   end

      #   it 'returns 400' do
      #     is_expected.to eq 400
      #     expect(body_hash['error']['code']).to eq 'sms_send_limit'
      #   end
      # end

      context 'when rate limit by 10/user/24hours' do
        let(:sms_verifiers) {
          create_list(:users__sms_verifier, 10, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 23.hours.from_now, remaining_attempts: 5, verifier_type: :registration)
        }
        let(:params) {
          {
            phone_number: '08012345678',
            phone_country_code: '81',
          }
        }

        before do
          sms_verifiers
        end

        it 'returns 400' do
          is_expected.to eq 400
          expect(body_hash['error']['code']).to eq 'sms_send_limit'
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
    let(:deleted_user) {
      create(:user, :skip_validate, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: 'Password1234!', email_verified: true, enabled: true, phone_number: '+818012345678',
deleted: true, deleted_at: Time.zone.now,)
    }

    let(:sms_verifier) {
      create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', phone_number: '+818012345678', expired_at: 1.hour.from_now, remaining_attempts: 5,
verifier_type: :registration,)
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
      deleted_user
      sms_verifier
      other_sms_verifier
      other_user_sms_verifier
      allow(ExpirableCookie).to receive(:new).and_return(session_mock)
      allow(session_mock).to receive(:[]=).and_return(nil)
      allow(session_mock).to receive(:session_clear).and_return(nil)
      allow(session_mock).to receive(:[]) do |key|
        case key
        when :current_user_id
          current_user.id
        when :current_user_id_expired_at
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
        expect(body_hash['error']['code']).to eq 'invalid_code'
        expect(body_hash['error']['message']).to eq 'コードが間違っています'
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
        expect(body_hash['error']['code']).to eq 'expired_sms_verification_code'
        expect(body_hash['error']['message']).to eq 'コードの有効期限が切れています'
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
        expect(body_hash['error']['code']).to eq 'sms_verification_code_attempts_is_over'
        expect(body_hash['error']['message']).to eq 'コードの試行回数が上限に達しました'
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
        expect(body_hash['error']['code']).to eq 'sms_verification_code_used'
        expect(body_hash['error']['message']).to eq '指定されたコードはすでに使用済みです'
      end
    end

    # codeは低確率で被る可能性がある。新しいものが選択されることを確認
    context 'when old code is duplicated' do
      let(:sms_verifier) {
        create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, used_at: nil,
verifier_type: :registration,)
      }
      let(:params) {
        {
          sms_verification_code: '123456',
        }
      }

      let(:old_sms_verifier) {
        create(:users__sms_verifier, tenant_id: current_tenant.id, user: current_user, code: '123456', expired_at: 1.hour.from_now, remaining_attempts: 5, used_at: 1.hour.ago,
verifier_type: :registration, created_at: 1.hour.ago,)
      }

      before do
        old_sms_verifier
      end

      it 'returns 200' do
        is_expected.to eq 200
      end
    end
  end
end
