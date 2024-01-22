# typed: false

RSpec.describe '[ Profiles API ]' do
  describe 'GET /api/v1/internal/me/profile' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    before do
      current_user
      current_user_profile
      current_user_contact_address
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end


    context 'when present session' do
      include_context 'current user session is present'

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['profile']['first_name']).to eq('太郎')
        expect(body_hash['profile']['last_name']).to eq('山田')
        expect(body_hash['profile']['first_name_kana']).to eq('タロウ')
        expect(body_hash['profile']['last_name_kana']).to eq('ヤマダ')
        expect(body_hash['profile']['birth_date']).to eq('1990-01-01')
        expect(body_hash['profile']['gender']).to eq('male')
        expect(body_hash['contact_address']['prefecture_code']).to eq('13')
        expect(body_hash['contact_address']['prefecture']).to eq('東京都')
        expect(body_hash['contact_address']['zip_code']).to eq('155-0033')
        expect(body_hash['contact_address']['city']).to eq('世田谷区代田')
        expect(body_hash['contact_address']['street']).to eq('1-1-1')
        expect(body_hash['contact_address']['building']).to eq('代田アモーレ 101号室')
        expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
      end
    end
  end

  describe 'PUT /api/v1/internal/me/profile' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    before do
      current_user
    end

    context 'when no session' do
      let(:params) {
        {
          user: {
            user_profile_attributes: {
              first_name: '太郎',
              last_name: '山田',
              first_name_kana: 'タロウ',
              last_name_kana: 'ヤマダ',
              birth_date: '2000-01-11',
              gender: 'male',
            },
            contact_address_attributes: {
              zip_code: '155-0033',
              prefecture_code: '13',
              city: '世田谷区代田',
              street: '５丁目１３−８',
              building: '代田フラット101',
            },
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      include_context 'current user session is present'



      context 'when params valid' do
        let(:params) {
          {
            user: {
              user_profile_attributes: {
                first_name: '太郎ニ',
                last_name: '山田ニ',
                first_name_kana: 'タロウツー',
                last_name_kana: 'ヤマダツー',
                birth_date: '2010-01-11',
                gender: 'male',
              },
              contact_address_attributes: {
                zip_code: '155-0031',
                prefecture_code: '13',
                city: '世田谷区北沢',
                street: '1丁目1-1',
                building: 'グレートオウル北沢101',
                phone_number: '090-1234-5678',
              },
            },
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['profile']['first_name']).to eq('太郎ニ')
          expect(body_hash['profile']['last_name']).to eq('山田ニ')
          expect(body_hash['profile']['first_name_kana']).to eq('タロウツー')
          expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
          expect(body_hash['profile']['birth_date']).to eq('2010-01-11')
          expect(body_hash['profile']['gender']).to eq('male')
          expect(body_hash['contact_address']['prefecture_code']).to eq('13')
          expect(body_hash['contact_address']['prefecture']).to eq('東京都')
          expect(body_hash['contact_address']['zip_code']).to eq('155-0031')
          expect(body_hash['contact_address']['city']).to eq('世田谷区北沢')
          expect(body_hash['contact_address']['street']).to eq('1丁目1-1')
          expect(body_hash['contact_address']['building']).to eq('グレートオウル北沢101')
          expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
        end
      end

      context 'when user profile already set' do
        let(:current_user_profile) {
          create(:user_profile,
            tenant_id: current_tenant.id, user_id: current_user.id, first_name: '設定済み名', first_name_kana: 'セッテイズミメイ',
            last_name: '設定済み姓', last_name_kana: 'セッテイズミセイ', birth_date: '2000-01-01', gender: 'female',)
        }
        let(:params) {
          {
            user: {
              user_profile_attributes: {
                first_name: '太郎ニ',
                last_name: '山田ニ',
                first_name_kana: 'タロウツー',
                last_name_kana: 'ヤマダツー',
                birth_date: '2010-01-11',
                gender: 'male',
              },
              contact_address_attributes: {
                zip_code: '155-0031',
                prefecture_code: '13',
                city: '世田谷区北沢',
                street: '1丁目1-1',
                building: 'グレートオウル北沢101',
                phone_number: '090-1234-5678',
              },
            },
          }
        }

        before do
          current_user_profile
        end


        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['profile']['first_name']).to eq('設定済み名')
          expect(body_hash['profile']['last_name']).to eq('山田ニ')
          expect(body_hash['profile']['first_name_kana']).to eq('セッテイズミメイ')
          expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
          expect(body_hash['profile']['birth_date']).to eq('2000-01-01')
          expect(body_hash['profile']['gender']).to eq('female')
          expect(body_hash['contact_address']['prefecture_code']).to eq('13')
          expect(body_hash['contact_address']['prefecture']).to eq('東京都')
          expect(body_hash['contact_address']['zip_code']).to eq('155-0031')
          expect(body_hash['contact_address']['city']).to eq('世田谷区北沢')
          expect(body_hash['contact_address']['street']).to eq('1丁目1-1')
          expect(body_hash['contact_address']['building']).to eq('グレートオウル北沢101')
          expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
        end
      end

      context 'when params invalid' do
        let(:params) {
          {
            user: {
              user_profile_attributes: {
                first_name: nil,
                last_name: nil,
                first_name_kana: nil,
                last_name_kana: nil,
                birth_date: nil,
                gender: nil,
              },
              contact_address_attributes: {
                zip_code: nil,
                prefecture_code: nil,
                city: nil,
                street: nil,
                building: nil,
              },
            },
          }
        }

        it 'returns 400' do
          is_expected.to eq 400
        end
      end

      context 'when given overseas address' do
        let(:params) {
          {
            user: {
              user_profile_attributes: {
                first_name: '太郎ニ',
                last_name: '山田ニ',
                first_name_kana: 'タロウツー',
                last_name_kana: 'ヤマダツー',
                birth_date: '2010-01-11',
                gender: 'male',
              },
              contact_address_attributes: {
                zip_code: nil,
                prefecture_code: '99',
                city: nil,
                street: nil,
                building: nil,
                country_code: 'CN',
              },
            },
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_hash['profile']['first_name']).to eq('太郎ニ')
          expect(body_hash['profile']['last_name']).to eq('山田ニ')
          expect(body_hash['profile']['first_name_kana']).to eq('タロウツー')
          expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
          expect(body_hash['profile']['birth_date']).to eq('2010-01-11')
          expect(body_hash['profile']['gender']).to eq('male')
          expect(body_hash['contact_address']['prefecture_code']).to eq('99')
          expect(body_hash['contact_address']['prefecture']).to eq('その他海外')
          expect(body_hash['contact_address']['zip_code']).to be_nil
          expect(body_hash['contact_address']['city']).to be_nil
          expect(body_hash['contact_address']['street']).to be_nil
          expect(body_hash['contact_address']['building']).to be_nil
          expect(body_hash['contact_address']['country_code']).to eq('CN')
        end
      end

      context 'when password already set' do
        let(:current_user) {
          create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: 'password_digest', enabled: false)
        }
        let(:sms_verification_required) { true }
        let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }

        let(:params) {
          {
            user: {
              user_profile_attributes: {
                first_name: '太郎ニ',
                last_name: '山田ニ',
                first_name_kana: 'タロウツー',
                last_name_kana: 'ヤマダツー',
                birth_date: '2010-01-11',
                gender: 'male',
              },
              contact_address_attributes: {
                zip_code: nil,
                prefecture_code: '99',
                city: nil,
                street: nil,
                building: nil,
                country_code: 'CN',
              },
            },
          }
        }

        context 'when sms verification not required' do
          let(:sms_verification_required) { false }

          it 'should be set enabled to true' do
            is_expected.to eq 200
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when sms verification required' do
          let(:sms_verification_required) { true }

          it 'should be set enabled to true' do
            is_expected.to eq 200
            expect(body_hash['enabled']).to be false
          end
        end

        context 'when sms verification required and sms verified' do
          let(:sms_verification_required) { true }
          let(:current_user) {
            create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: 'password_digest', enabled: false, sms_verified: true, phone_number: '+819012345678')
          }

          it 'should be set enabled to true' do
            is_expected.to eq 200
            expect(body_hash['enabled']).to be true
          end
        end
      end
    end
  end
end
