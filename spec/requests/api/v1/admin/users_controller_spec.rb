# typed: false

RSpec.describe '[ Admin Users API ]' do
  describe 'GET /api/v1/admin/users' do
    let(:oauth_application) {
      OauthApplication.create!(
        tenant_id: current_tenant.id,
        name: 'Sample',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        scopes: 'admin_users uid email name profile contact delivery_address openid',
        enable_client_credential_flow: true,
      )
    }
    let(:headers) {
      {
        Authorization: "Bearer #{oauth_token.token}",
        'Content-Type': 'application/x-www-form-urlencoded', # query paramsを指定する場合これ
      }
    }
    let(:token_expires_in) { 2.hours }
    let(:scopes) { 'admin_users uid email name profile contact delivery_address' }
    let(:oauth_token) {
      OauthAccessToken.create!(
        tenant_id: current_tenant.id,
        application_id: oauth_application.id,
        resource_owner_id: nil,
        scopes:,
        expires_in: token_expires_in,
        created_at: Time.current,
        revoked_at: nil,
      )
    }

    let(:other_users) {
      create_list(:user, 3, tenant_id: current_tenant.id) do |user|
        create(:user_profile, tenant_id: current_tenant.id, user:)
        create(:contact_address, tenant_id: current_tenant.id, user:)
        create(:delivery_address, tenant_id: current_tenant.id, user:)
      end
    }

    before do
      other_users
    end


    context 'when token is blank' do
      let(:headers) { {} }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when linked users are do not present' do
      it 'returns 200' do
        is_expected.to eq 200
        expect(body_array).to eq([])
      end
    end

    context 'when many linked users are present' do
      let(:first_user) {
        create(:user, tenant_id: current_tenant.id, email: 'test-first-user@example.com') do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:)
          create(:contact_address, tenant_id: current_tenant.id, user:)
          create(:delivery_address, tenant_id: current_tenant.id, user:)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }
      let(:users) {
        create_list(:user, 60, tenant_id: current_tenant.id) do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:)
          create(:contact_address, tenant_id: current_tenant.id, user:)
          create(:delivery_address, tenant_id: current_tenant.id, user:)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }

      before do
        first_user
        users
      end

      context 'when pagination params are blank' do
        it 'returns 200' do
          is_expected.to eq 200
          expect(body_array[0]['email']).to eq('test-first-user@example.com')
          expect(body_array[0]['delivery_addresses'][0]['is_default']).to be(false)
          expect(body_array[0]['delivery_addresses'][0]['prefecture_code']).to eq('13')
          expect(body_array[0]['delivery_addresses'][0]['prefecture']).to eq('東京都')
          expect(body_array[0]['delivery_addresses'][0]['zip_code']).to eq('155-0033')
          expect(body_array[0]['delivery_addresses'][0]['city']).to eq('世田谷区代田')
          expect(body_array[0]['delivery_addresses'][0]['street']).to eq('1-1-1')
          expect(body_array[0]['delivery_addresses'][0]['building']).to eq('代田アモーレ 101号室')
          expect(body_array[0]['delivery_addresses'][0]['phone_number']).to eq('090-1234-5678')
          expect(body_array[0]['delivery_addresses'][0]['country_code']).to eq('JP')
          expect(body_array[0]['profile']['first_name']).to eq('太郎')
          expect(body_array[0]['profile']['last_name']).to eq('山田')
          expect(body_array[0]['profile']['first_name_kana']).to eq('タロウ')
          expect(body_array[0]['profile']['last_name_kana']).to eq('ヤマダ')
          expect(body_array[0]['profile']['birth_date']).to eq('1990-01-01')
          expect(body_array[0]['profile']['gender']).to eq('male')
          expect(body_array[0]['contact_address']['prefecture_code']).to eq('13')
          expect(body_array[0]['contact_address']['prefecture']).to eq('東京都')
          expect(body_array[0]['contact_address']['zip_code']).to eq('155-0033')
          expect(body_array[0]['contact_address']['city']).to eq('世田谷区代田')
          expect(body_array[0]['contact_address']['street']).to eq('1-1-1')
          expect(body_array[0]['contact_address']['building']).to eq('代田アモーレ 101号室')
          expect(body_array[0]['contact_address']['phone_number']).to eq('090-1234-5678')
          expect(body_array[0]['contact_address']['country_code']).to eq('JP')
          expect(body_array.count).to eq(20)
        end
      end


      context 'when per_page is 10' do
        let(:params) {
          {
            page: 1,
            per_page: 10,
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_array.count).to eq(10)
        end
      end

      context 'when per_page is 60' do
        let(:params) {
          {
            page: 1,
            per_page: 60,
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          # max_per_pageは50
          expect(body_array.count).to eq(50)
        end
      end

      context 'when page is 2' do
        let(:params) {
          {
            page: 2,
            per_page: 50,
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_array.count).to eq(11)
        end
      end
    end


    context 'when there is users who has updated their profile' do
      # 何も更新していないユーザー
      let(:no_touch_user) {
        create(:user, tenant_id: current_tenant.id, email: 'no_touch_user@example.com', updated_at: 10.days.ago) do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:contact_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:delivery_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }
      # user.updated_atが更新されたユーザー
      let(:email_updated_user) {
        create(:user, tenant_id: current_tenant.id, email: 'email_updated_user@example.com', updated_at: 1.day.ago) do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:contact_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:delivery_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }
      # profile.updated_atが更新されたユーザー
      let(:profile_updated_user) {
        create(:user, tenant_id: current_tenant.id, email: 'profile_updated_user@example.com', updated_at: 10.days.ago) do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:, updated_at: 1.day.ago)
          create(:contact_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:delivery_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }
      # contact_address.updated_atが更新されたユーザー
      let(:contact_address_updated_user) {
        create(:user, tenant_id: current_tenant.id, email: 'contact_address_updated_user@example.com', updated_at: 10.days.ago) do |user|
          create(:user_profile, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:contact_address, tenant_id: current_tenant.id, user:, updated_at: 1.day.ago)
          create(:delivery_address, tenant_id: current_tenant.id, user:, updated_at: 10.days.ago)
          create(:users__linked_application, tenant_id: current_tenant.id, user:, oauth_application:)
        end
      }

      before do
        no_touch_user
        email_updated_user
        profile_updated_user
        contact_address_updated_user
      end

      context 'when given start_at and end_at' do
        let(:params) {
          {
            start_at: 5.days.ago.iso8601,
            end_at: Time.zone.now.iso8601,
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_array.count).to eq(3)
          expect(body_array[0]['email']).to eq('email_updated_user@example.com')
          expect(body_array[1]['email']).to eq('profile_updated_user@example.com')
          expect(body_array[2]['email']).to eq('contact_address_updated_user@example.com')
        end
      end

      context 'when given start_at and end_at, pagination params' do
        let(:params) {
          {
            start_at: 5.days.ago.iso8601,
            end_at: Time.zone.now.iso8601,
            page: 2,
            per_page: 2,
          }
        }

        it 'returns 200' do
          is_expected.to eq 200
          expect(body_array.count).to eq(1)
        end
      end
    end
  end

  describe 'GET /api/v1/admin/users/:user_id' do
    let(:oauth_application) {
      OauthApplication.create!(
        tenant_id: current_tenant.id,
        name: 'Sample',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        scopes: 'admin_users uid email name profile contact delivery_address openid',
        enable_client_credential_flow: true,
      )
    }
    let(:token_expires_in) { 2.hours }
    let(:user) { create(:user, tenant_id: current_tenant.id) }
    let(:user_profile) { create(:user_profile, tenant_id: current_tenant.id, user:) }
    let(:contact_address) { create(:contact_address, tenant_id: current_tenant.id, user:) }
    let(:delivery_address) { create(:delivery_address, tenant_id: current_tenant.id, user:) }
    let(:user_id) { user.id }

    context 'when present vaild access token' do
      let(:scopes) { 'admin_users uid email name profile contact delivery_address' }
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: nil,
          scopes:,
          expires_in: token_expires_in,
          created_at: Time.current,
          revoked_at: nil,
        )
      }
      let(:headers) {
        {
          Authorization: "Bearer #{oauth_token.token}",
        }
      }

      before do
        oauth_token
        user_profile
        contact_address
        delivery_address
      end

      context 'when has all scopes' do
        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'uid' => user.id,
            'email' => user.email,
            'deleted' => false,
            'delivery_addresses' => [
              {
                'is_default' => delivery_address.is_default,
                'prefecture_code' => delivery_address.prefecture_code_jis,
                'prefecture' => delivery_address.prefecture.name,
                'zip_code' => delivery_address.zip_code,
                'city' => delivery_address.city,
                'street' => delivery_address.street,
                'building' => delivery_address.building,
                'country_code' => 'JP',
                'phone_number' => delivery_address.phone_number,
              },
            ],
            'profile' => {
              'first_name' => user_profile.first_name,
              'last_name' => user_profile.last_name,
              'first_name_kana' => user_profile.first_name_kana,
              'last_name_kana' => user_profile.last_name_kana,
              'birth_date' => user_profile.birth_date.strftime('%Y-%m-%d'),
              'gender' => user_profile.gender,
            },
            'contact_address' => {
              'prefecture_code' => contact_address.prefecture_code_jis,
              'prefecture' => contact_address.prefecture.name,
              'zip_code' => contact_address.zip_code,
              'city' => contact_address.city,
              'street' => contact_address.street,
              'building' => contact_address.building,
              'country_code' => 'JP',
              'phone_number' => contact_address.phone_number,
            },
          })
        end
      end
    end

    context 'when token is blank' do
      it 'returns http status 401' do
        is_expected.to eq 401
      end
    end

    context 'when token is expired' do
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: nil,
          scopes: 'public openid',
          expires_in: token_expires_in,
          created_at: 1.day.ago,
          revoked_at: nil,
        )
      }

      let(:headers) {
        {
          Authorization: "Bearer #{oauth_token.token}",
          'Content-Type': 'application/json',
        }
      }

      before do
        oauth_token
      end

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when donot have admin_users scopes' do
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: user.id,
          scopes: 'public openid',
          expires_in: token_expires_in,
          created_at: Time.current,
          revoked_at: nil,
        )
      }

      let(:headers) {
        {
          Authorization: "Bearer #{oauth_token.token}",
          'Content-Type': 'application/json',
        }
      }

      before do
        oauth_token
      end

      it 'returns 403' do
        is_expected.to eq 403
      end
    end
  end
end
