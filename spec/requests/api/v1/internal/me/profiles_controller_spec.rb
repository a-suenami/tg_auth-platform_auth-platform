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
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest:, enabled: user_enabled, sms_verified:, phone_number: user_phone_number)
    }
    let(:user_enabled) { false }
    let(:password_digest) { 'password_digest' }
    let(:sms_verified) { false }
    let(:user_phone_number) { nil }
    let(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: 'registered',
        subject: '登録完了メール',
        body: <<~TEXT,
          <p>登録完了しました</p>
          <p>{{ email }}</p>
        TEXT
      )
    }

    before do
      current_user
      email_template
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
        let(:user_enabled) { false }
        let(:password_digest) { 'password_digest' }

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
          let(:user_enabled) { false }
          let(:password_digest) { 'password_digest' }
          let(:sms_verified) { true }
          let(:user_phone_number) { '+819012345678' }

          it 'should be set enabled to true' do
            is_expected.to eq 200
            expect(body_hash['enabled']).to be true
          end
        end
      end

      # profile_field_rulesが設定されていない場合、デフォルトの値が使用されるかどうかの確認。
      context 'when profile_field_rules not set' do
        context 'when given all required params' do
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
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when given all required params and password_digest is nil' do
          let(:password_digest) { nil }

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
            expect(body_hash['enabled']).to be false # password_digestがnilなのでfalseのまま
          end
        end

        context 'when given all required params and sms verification required and not sms verified' do
          let(:sms_verification_required) { true }
          let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }
          let(:sms_verified) { false }
          let(:user_phone_number) { nil }

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
            expect(body_hash['enabled']).to be false # sms verifiedがfalseなのでfalseのまま
          end
        end

        context 'when given all param is empty' do
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
                  phone_number: nil,
                },
              },
            }
          }


          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'user_profile.first_name',
              'user_profile.last_name',
              'user_profile.first_name_kana',
              'user_profile.last_name_kana',
              'user_profile.birth_date',
              'user_profile.gender',
              'contact_address.zip_code',
              'contact_address.prefecture_code',
              'contact_address.city',
              'contact_address.street',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
          end
        end

        context 'when some required items are not met' do
          let(:params) {
            {
              user: {
                user_profile_attributes: {
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
                },
              },
            }
          }

          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'user_profile.first_name',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
          end
        end
      end

      context 'when profile_field_rules set(user_profile + phone_number)' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: true,
                hidden: false,
                editable: false,
              },
              last_name: {
                required: true,
                hidden: false,
                editable: true,
              },
              first_name_kana: {
                required: true,
                hidden: false,
                editable: false,
              },
              last_name_kana: {
                required: true,
                hidden: false,
                editable: true,
              },
              birth_date: {
                required: true,
                hidden: false,
                editable: false,
              },
              gender: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
            contact_address: {
              zip_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              prefecture_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              city: {
                required: false,
                hidden: false,
                editable: true,
              },
              street: {
                required: false,
                hidden: false,
                editable: true,
              },
              building: {
                required: false,
                hidden: false,
                editable: true,
              },
              phone_number: {
                required: true,
                hidden: false,
                editable: true,
              },
              country_code: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when given all required params' do
          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
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
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when given all required params and password_digest is nil' do
          let(:password_digest) { nil }
          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
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
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['enabled']).to be false # password_digestがnilなのでfalseのまま
          end
        end

        context 'when given all required params and sms verification required and not sms verified' do
          let(:sms_verification_required) { true }
          let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }
          let(:sms_verified) { false }
          let(:user_phone_number) { nil }

          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
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
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['enabled']).to be false # sms verifiedがfalseなのでfalseのまま
          end
        end

        context 'when given all required params and sms verification required and sms verified' do
          let(:sms_verification_required) { true }
          let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com', sms_verification_required:) }
          let(:sms_verified) { true }
          let(:user_phone_number) { '+819012345678' }

          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
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
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when some required items are not met' do
          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: nil,
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
                  # phone_number: '090-1234-5678',
                },
              },
            }
          }

          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'user_profile.first_name',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
            expect(current_user.reload.enabled).to be false
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
            expect(body_hash['profile']['gender']).to eq('male')
            expect(body_hash['contact_address']['prefecture_code']).to eq('13')
            expect(body_hash['contact_address']['prefecture']).to eq('東京都')
            expect(body_hash['contact_address']['zip_code']).to eq('155-0031')
            expect(body_hash['contact_address']['city']).to eq('世田谷区北沢')
            expect(body_hash['contact_address']['street']).to eq('1丁目1-1')
            expect(body_hash['contact_address']['building']).to eq('グレートオウル北沢101')
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(current_user.reload.enabled).to be true
          end
        end
      end

      context 'when user_profiles attributes are not required' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: false,
                hidden: false,
                editable: true,
              },
              last_name: {
                required: false,
                hidden: false,
                editable: true,
              },
              first_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              last_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              birth_date: {
                required: false,
                hidden: false,
                editable: true,
              },
              gender: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
            contact_address: {
              zip_code: {
                required: true,
                hidden: false,
                editable: true,
              },
              prefecture_code: {
                required: true,
                hidden: false,
                editable: true,
              },
              city: {
                required: true,
                hidden: false,
                editable: true,
              },
              street: {
                required: true,
                hidden: false,
                editable: true,
              },
              building: {
                required: true,
                hidden: false,
                editable: true,
              },
              phone_number: {
                required: true,
                hidden: false,
                editable: true,
              },
              country_code: {
                required: true,
                hidden: false,
                editable: true,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when given all required params' do
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
            expect(current_user.reload.user_profile).to be_nil
            expect(body_hash['contact_address']['prefecture_code']).to eq('13')
            expect(body_hash['contact_address']['prefecture']).to eq('東京都')
            expect(body_hash['contact_address']['zip_code']).to eq('155-0031')
            expect(body_hash['contact_address']['city']).to eq('世田谷区北沢')
            expect(body_hash['contact_address']['street']).to eq('1丁目1-1')
            expect(body_hash['contact_address']['building']).to eq('グレートオウル北沢101')
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['contact_address']['country_code']).to eq('JP')
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when some required items are not met' do
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
                  zip_code: '155-0031',
                  prefecture_code: '13',
                  city: '世田谷区北沢',
                  street: '1丁目1-1',
                  building: 'グレートオウル北沢101',
                  phone_number: nil,
                },
              },
            }
          }

          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'contact_address.phone_number',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
            expect(current_user.reload.enabled).to be false
          end
        end
      end


      context 'when contact_address attributes are not required' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: true,
                hidden: false,
                editable: true,
              },
              last_name: {
                required: true,
                hidden: false,
                editable: true,
              },
              first_name_kana: {
                required: true,
                hidden: false,
                editable: true,
              },
              last_name_kana: {
                required: true,
                hidden: false,
                editable: true,
              },
              birth_date: {
                required: true,
                hidden: false,
                editable: true,
              },
              gender: {
                required: true,
                hidden: false,
                editable: true,
              },
            },
            contact_address: {
              zip_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              prefecture_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              city: {
                required: false,
                hidden: false,
                editable: true,
              },
              street: {
                required: false,
                hidden: false,
                editable: true,
              },
              building: {
                required: false,
                hidden: false,
                editable: true,
              },
              phone_number: {
                required: false,
                hidden: false,
                editable: true,
              },
              country_code: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when given all required params' do
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
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
                  phone_number: nil,
                  country_code: nil,
                },
              },
            }
          }

          it 'returns 200' do
            is_expected.to eq 200
            expect(current_user.reload.contact_address).to be_nil
            expect(body_hash['profile']['first_name']).to eq('太郎ニ')
            expect(body_hash['profile']['last_name']).to eq('山田ニ')
            expect(body_hash['profile']['first_name_kana']).to eq('タロウツー')
            expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
            expect(body_hash['profile']['birth_date']).to eq('2010-01-11')
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when some required items are not met' do
          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
                  last_name: '山田ニ',
                  first_name_kana: 'タロウツー',
                  last_name_kana: 'ヤマダツー',
                  birth_date: '2010-01-11',
                  gender: nil,
                },
                contact_address_attributes: {
                  zip_code: nil,
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
                  phone_number: nil,
                  country_code: nil,
                },
              },
            }
          }

          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'user_profile.gender',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
            expect(current_user.reload.enabled).to be false
          end
        end

        # country_codeはdefaultでJPなので指定しないと勝手に設定される
        context 'when some required items are not met and country_code not define' do
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
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
                  phone_number: nil,
                },
              },
            }
          }

          it 'returns 200' do
            is_expected.to eq 200
            expect(current_user.reload.contact_address).to be_present
            expect(body_hash['profile']['first_name']).to eq('太郎ニ')
            expect(body_hash['profile']['last_name']).to eq('山田ニ')
            expect(body_hash['profile']['first_name_kana']).to eq('タロウツー')
            expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
            expect(body_hash['profile']['birth_date']).to eq('2010-01-11')
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to be_nil
            expect(body_hash['contact_address']['country_code']).to eq('JP')
            expect(body_hash['enabled']).to be true
          end
        end
      end

      context 'when all attribute are not required' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: false,
                hidden: false,
                editable: true,
              },
              last_name: {
                required: false,
                hidden: false,
                editable: true,
              },
              first_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              last_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              birth_date: {
                required: false,
                hidden: false,
                editable: true,
              },
              gender: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
            contact_address: {
              zip_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              prefecture_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              city: {
                required: false,
                hidden: false,
                editable: true,
              },
              street: {
                required: false,
                hidden: false,
                editable: true,
              },
              building: {
                required: false,
                hidden: false,
                editable: true,
              },
              phone_number: {
                required: false,
                hidden: false,
                editable: true,
              },
              country_code: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when given all required params' do
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
                  phone_number: nil,
                  country_code: nil,
                },
              },
            }
          }

          it 'returns 200' do
            is_expected.to eq 200
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
            expect(body_hash['enabled']).to be true
          end
        end
      end

      context 'when all attribute are required and not editable' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: true,
                hidden: false,
                editable: false,
              },
              last_name: {
                required: true,
                hidden: false,
                editable: false,
              },
              first_name_kana: {
                required: true,
                hidden: false,
                editable: false,
              },
              last_name_kana: {
                required: true,
                hidden: false,
                editable: false,
              },
              birth_date: {
                required: true,
                hidden: false,
                editable: false,
              },
              gender: {
                required: true,
                hidden: false,
                editable: false,
              },
            },
            contact_address: {
              zip_code: {
                required: true,
                hidden: false,
                editable: false,
              },
              prefecture_code: {
                required: true,
                hidden: false,
                editable: false,
              },
              city: {
                required: true,
                hidden: false,
                editable: false,
              },
              street: {
                required: true,
                hidden: false,
                editable: false,
              },
              building: {
                required: true,
                hidden: false,
                editable: false,
              },
              phone_number: {
                required: true,
                hidden: false,
                editable: false,
              },
              country_code: {
                required: true,
                hidden: false,
                editable: false,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when first time' do
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
                  country_code: 'JP',
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
            expect(body_hash['contact_address']['country_code']).to eq('JP')
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when user profile already set' do
          let(:current_user_profile) {
            create(:user_profile,
              tenant_id: current_tenant.id, user_id: current_user.id, first_name: '設定済み名', first_name_kana: 'セッテイズミメイ',
              last_name: '設定済み姓', last_name_kana: 'セッテイズミセイ', birth_date: '2000-01-01', gender: 'female',)
          }
          let(:current_contact_address) {
            create(:contact_address,
              tenant_id: current_tenant.id, user_id: current_user.id, zip_code: '530-0001', # 郵便番号を変更
              prefecture_code: '27', city: '大阪市北区', # 都道府県コードと市区町村を変更
              street: '梅田1丁目1-1', building: '梅田ビル101', # 通りと建物名を変更
              phone_number: '06-1234-5678', country_code: 'JP',) # 電話番号を変更
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
                  country_code: 'JP',
                },
              },
            }
          }

          before do
            current_user_profile
            current_contact_address
          end

          it 'returns 200' do
            is_expected.to eq 200
            expect(body_hash['profile']['first_name']).to eq('設定済み名')
            expect(body_hash['profile']['last_name']).to eq('設定済み姓')
            expect(body_hash['profile']['first_name_kana']).to eq('セッテイズミメイ')
            expect(body_hash['profile']['last_name_kana']).to eq('セッテイズミセイ')
            expect(body_hash['profile']['birth_date']).to eq('2000-01-01')
            expect(body_hash['profile']['gender']).to eq('female')
            expect(body_hash['contact_address']['prefecture_code']).to eq('27')
            expect(body_hash['contact_address']['prefecture']).to eq('大阪府')
            expect(body_hash['contact_address']['zip_code']).to eq('530-0001')
            expect(body_hash['contact_address']['city']).to eq('大阪市北区')
            expect(body_hash['contact_address']['street']).to eq('梅田1丁目1-1')
            expect(body_hash['contact_address']['building']).to eq('梅田ビル101')
            expect(body_hash['contact_address']['phone_number']).to eq('06-1234-5678')
            expect(body_hash['contact_address']['country_code']).to eq('JP')
            expect(body_hash['enabled']).to be true

            # 一応user_profile, contact_addressが増えていないことを確認
            expect(UserProfile.where(user: current_user).count).to eq 1
            expect(ContactAddress.where(user: current_user).count).to eq 1
          end
        end

        # 海外住所が指定された場合は、強制的に住所は入力しなくても良い
        context 'when given coutnry_code is not JP' do
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
                  prefecture_code: nil,
                  city: nil,
                  street: nil,
                  building: nil,
                  phone_number: '090-1234-5678',
                  country_code: 'US',
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
            expect(body_hash['contact_address']['prefecture_code']).to be_nil
            expect(body_hash['contact_address']['prefecture']).to be_nil
            expect(body_hash['contact_address']['zip_code']).to be_nil
            expect(body_hash['contact_address']['city']).to be_nil
            expect(body_hash['contact_address']['street']).to be_nil
            expect(body_hash['contact_address']['building']).to be_nil
            expect(body_hash['contact_address']['phone_number']).to eq('090-1234-5678')
            expect(body_hash['contact_address']['country_code']).to eq('US')
            expect(body_hash['enabled']).to be true
          end
        end
      end

      context 'when only first_name is required' do
        let(:profile_field_rules) {
          {
            user_profiles: {
              first_name: {
                required: true,
                hidden: false,
                editable: true,
              },
              last_name: {
                required: false,
                hidden: false,
                editable: true,
              },
              first_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              last_name_kana: {
                required: false,
                hidden: false,
                editable: true,
              },
              birth_date: {
                required: false,
                hidden: false,
                editable: true,
              },
              gender: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
            contact_address: {
              zip_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              prefecture_code: {
                required: false,
                hidden: false,
                editable: true,
              },
              city: {
                required: false,
                hidden: false,
                editable: true,
              },
              street: {
                required: false,
                hidden: false,
                editable: true,
              },
              building: {
                required: false,
                hidden: false,
                editable: true,
              },
              phone_number: {
                required: false,
                hidden: false,
                editable: true,
              },
              country_code: {
                required: false,
                hidden: false,
                editable: true,
              },
            },
          }.to_json
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, google_cloud_service_account: {}, google_cloud_project_id: 'project_id', recaptcha_enterprise_checkbox_site_key: 'checkbox_site_key',
            recaptcha_enterprise_score_based_site_key: 'score_based_site_key', profile_field_rules:,)
        }

        before do
          tenant_setting
        end

        context 'when given all required params' do
          let(:params) {
            {
              user: {
                user_profile_attributes: {
                  first_name: '太郎ニ',
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
                  phone_number: nil,
                  country_code: nil,
                },
              },

            }
          }

          it 'returns 200' do
            is_expected.to eq 200
            expect(current_user.reload.user_profile).to be_present
            expect(current_user.reload.contact_address).to be_nil
            expect(body_hash['profile']['first_name']).to eq('太郎ニ')
            expect(body_hash['profile']['last_name']).to be_nil
            expect(body_hash['profile']['first_name_kana']).to be_nil
            expect(body_hash['profile']['last_name_kana']).to be_nil
            expect(body_hash['profile']['birth_date']).to be_nil
            expect(body_hash['enabled']).to be true
          end
        end

        context 'when some required items are not met' do
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
                  phone_number: nil,
                  country_code: nil,
                },
              },
            }
          }

          it 'returns 400' do
            is_expected.to eq 400
            # params.messages のキーを取得
            body_hash['error']['params']['messages'].keys.map(&:strip)

            # エラーが期待される属性
            expected_attributes = [
              'user_profile.first_name',
            ]

            # ヘルパーメソッドを使用
            expect_attributes_in_error_messages(body_hash, expected_attributes)

            # user_profile, contact_addressが作成されていないことを確認
            expect(current_user.reload.user_profile).to be_nil
            expect(current_user.reload.contact_address).to be_nil
            expect(current_user.reload.enabled).to be false
          end
        end
      end

      context 'when only 1 attribute required in user profiles' do
        let(:profile_field_rules) {
          updated_profile_field_rules(base_profile_field_rules, required_field)
        }

        let(:base_profile_field_rules) {
          {
            user_profiles: {
              first_name: { required: false, hidden: false, editable: true },
              last_name: { required: false, hidden: false, editable: true },
              first_name_kana: { required: false, hidden: false, editable: true },
              last_name_kana: { required: false, hidden: false, editable: true },
              birth_date: { required: false, hidden: false, editable: true },
              gender: { required: false, hidden: false, editable: true },
            },
            contact_address: {
              zip_code: { required: false, hidden: false, editable: true },
              prefecture_code: { required: false, hidden: false, editable: true },
              city: { required: false, hidden: false, editable: true },
              street: { required: false, hidden: false, editable: true },
              building: { required: false, hidden: false, editable: true },
              phone_number: { required: false, hidden: false, editable: true },
              country_code: { required: false, hidden: false, editable: true },
            },
          }
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, profile_field_rules: profile_field_rules.to_json)
        }

        let(:params) {
          {
            user: {
              user_profile_attributes: user_profile_params,
              contact_address_attributes: contact_address_params,
            },
          }
        }

        let(:contact_address_params) do
          {
            zip_code: nil,
            prefecture_code: nil,
            city: nil,
            street: nil,
            building: nil,
            phone_number: nil,
            country_code: nil,
          }
        end

        before do
          tenant_setting
        end

        shared_examples 'user profile validation' do |field_name, value|
          context "when #{field_name} is required" do
            let(:required_field) { field_name } # テストごとに必須フィールドを切り替える

            context 'when all required params are met' do
              let(:user_profile_params) do
                { field_name => value }.with_indifferent_access
              end

              it 'returns 200' do
                is_expected.to eq 200
                expect(current_user.reload.user_profile).to be_present
                expect(current_user.reload.contact_address).to be_nil
                expect(body_hash['profile'][field_name.to_s]).to eq(value)
              end
            end

            context 'when required params are missing' do
              let(:user_profile_params) do
                { field_name => nil }.with_indifferent_access
              end

              it 'returns 400' do
                is_expected.to eq 400

                # エラーが期待される属性
                expected_attributes = ["user_profile.#{field_name}"]

                # ヘルパーメソッドでエラーメッセージを確認
                expect_attributes_in_error_messages(body_hash, expected_attributes)

                # user_profile, contact_addressが作成されていないことを確認
                expect(current_user.reload.user_profile).to be_nil
                expect(current_user.reload.contact_address).to be_nil
              end
            end
          end
        end

        # user_profilesの全項目についてテストを実行
        {
          first_name: '太郎',
          last_name: '山田',
          first_name_kana: 'タロウ',
          last_name_kana: 'ヤマダ',
          birth_date: '2000-01-01',
          gender: 'male',
        }.each do |field, value|
          include_examples 'user profile validation', field, value
        end

        # 必須フィールドを正しく上書きするヘルパーメソッド
        def updated_profile_field_rules(rules, required_field)
          # rulesをdeep_dupして直接上書きしないようにする
          updated_rules = Marshal.load(Marshal.dump(rules))
          updated_rules[:user_profiles].each do |field, options|
            options[:required] = (field == required_field) # 対象項目だけをtrueに
          end
          updated_rules
        end
      end

      context 'when only 1 attribute required in contact address' do
        let(:profile_field_rules) {
          updated_profile_field_rules(base_profile_field_rules, required_field)
        }

        let(:base_profile_field_rules) {
          {
            user_profiles: {
              first_name: { required: false, hidden: false, editable: true },
              last_name: { required: false, hidden: false, editable: true },
              first_name_kana: { required: false, hidden: false, editable: true },
              last_name_kana: { required: false, hidden: false, editable: true },
              birth_date: { required: false, hidden: false, editable: true },
              gender: { required: false, hidden: false, editable: true },
            },
            contact_address: {
              zip_code: { required: false, hidden: false, editable: true },
              prefecture_code: { required: false, hidden: false, editable: true },
              city: { required: false, hidden: false, editable: true },
              street: { required: false, hidden: false, editable: true },
              building: { required: false, hidden: false, editable: true },
              phone_number: { required: false, hidden: false, editable: true },
              country_code: { required: false, hidden: false, editable: true },
            },
          }
        }

        let(:tenant_setting) {
          create(:tenant_setting, tenant_id: current_tenant.id, profile_field_rules: profile_field_rules.to_json)
        }

        let(:params) {
          {
            user: {
              user_profile_attributes: user_profile_params,
              contact_address_attributes: contact_address_params,
            },
          }
        }

        let(:user_profile_params) { {} }

        let(:contact_address_params) { {} }

        before do
          tenant_setting
        end

        shared_examples 'contact address validation' do |field_name, value|
          context "when #{field_name} is required" do
            let(:required_field) { field_name } # テストごとに必須フィールドを切り替える

            context 'when all required params are met' do
              let(:contact_address_params) do
                { field_name => value }.with_indifferent_access
              end

              it 'returns 200' do
                is_expected.to eq 200
                expect(current_user.reload.user_profile).to be_nil
                expect(current_user.reload.contact_address).to be_present
                expect(body_hash['contact_address'][field_name.to_s]).to eq(value)
              end
            end

            context 'when required params are missing' do
              let(:contact_address_params) do
                { field_name => nil }.with_indifferent_access
              end

              it 'returns 400' do
                is_expected.to eq 400

                # エラーが期待される属性
                expected_attributes = ["contact_address.#{field_name}"]

                # ヘルパーメソッドでエラーメッセージを確認
                expect_attributes_in_error_messages(body_hash, expected_attributes)

                # user_profile, contact_addressが作成されていないことを確認
                expect(current_user.reload.user_profile).to be_nil
                expect(current_user.reload.contact_address).to be_nil
              end
            end
          end
        end

        # contact_addressの全項目についてテストを実行
        {
          zip_code: '123-4567',
          prefecture_code: '13',
          city: '東京都新宿区',
          street: '新宿1-1-1',
          building: '新宿ビル101',
          phone_number: '090-1234-5678',
          country_code: 'JP',
        }.each do |field, value|
          include_examples 'contact address validation', field, value
        end

        # 必須フィールドを正しく上書きするヘルパーメソッド
        def updated_profile_field_rules(rules, required_field)
          # rulesをdeep_dupして直接上書きしないようにする
          updated_rules = Marshal.load(Marshal.dump(rules))
          updated_rules[:contact_address].each do |field, options|
            options[:required] = (field == required_field) # 対象項目だけをtrueに
          end
          updated_rules
        end
      end
    end
  end
end
