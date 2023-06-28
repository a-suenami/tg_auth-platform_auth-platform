# typed: false

RSpec.describe '[ Userinfo API ]' do
  describe 'GET /api/v1/private/userinfo' do
    let(:oauth_application) {
      OauthApplication.create!(
        tenant_id: current_tenant.id,
        name: 'Sample',
        redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
        scopes: 'admin_users uid email name profile contact delivery_address openid',
      )
    }
    let(:token_expires_in) { 2.hours }
    let(:user_profile) { create(:user_profile, tenant_id: current_tenant.id, user: current_user) }
    let(:contact_address) { create(:contact_address, tenant_id: current_tenant.id, user: current_user) }
    let(:delivery_address) { create(:delivery_address, tenant_id: current_tenant.id, user: current_user) }

    context 'when present vaild access token' do
      let(:scopes) { '' }
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: current_user.id,
          scopes:,
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
        user_profile
        contact_address
        delivery_address
      end

      context 'when current user has all scopes' do
        let(:scopes) { 'uid email name profile contact delivery_address' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'uid' => current_user.id,
            'email' => current_user.email,
            'delivery_addresses' => [
              {
                'is_default' => delivery_address.is_default,
                'prefecture_code' => delivery_address.prefecture_code,
                'prefecture' => delivery_address.prefecture.name,
                'zip_code' => delivery_address.zip_code,
                'city' => delivery_address.city,
                'address_1' => delivery_address.address_1,
                'address_2' => delivery_address.address_2,
                'contact_tel' => delivery_address.contact_tel,
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
              'prefecture_code' => contact_address.prefecture_code,
              'prefecture' => contact_address.prefecture.name,
              'zip_code' => contact_address.zip_code,
              'city' => contact_address.city,
              'address_1' => contact_address.address_1,
              'address_2' => contact_address.address_2,
            },
          })
        end
      end

      context 'when current user has uid scopes' do
        let(:scopes) { 'uid' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'uid' => current_user.id,
          })
        end
      end

      context 'when current user has email scopes' do
        let(:scopes) { 'email' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'email' => current_user.email,
          })
        end
      end

      context 'when current user has name scopes' do
        let(:scopes) { 'name' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'profile' => {
              'first_name' => user_profile.first_name,
              'last_name' => user_profile.last_name,
              'first_name_kana' => user_profile.first_name_kana,
              'last_name_kana' => user_profile.last_name_kana,
            },
          })
        end
      end

      context 'when current user has profile scopes' do
        let(:scopes) { 'profile' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'profile' => {
              'birth_date' => user_profile.birth_date.strftime('%Y-%m-%d'),
              'gender' => user_profile.gender,
            },
            'contact_address' => {
              'prefecture_code' => contact_address.prefecture_code,
              'prefecture' => contact_address.prefecture.name,
            },
          })
        end
      end

      context 'when current user has contact scopes' do
        let(:scopes) { 'contact' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'contact_address' => {
              'prefecture_code' => contact_address.prefecture_code,
              'prefecture' => contact_address.prefecture.name,
              'zip_code' => contact_address.zip_code,
              'city' => contact_address.city,
              'address_1' => contact_address.address_1,
              'address_2' => contact_address.address_2,
            },
          })
        end
      end

      context 'when current user has delivery_address scopes' do
        let(:scopes) { 'delivery_address' }

        it 'returns user info' do
          is_expected.to eq 200
          expect(body_hash).to eq({
            'delivery_addresses' => [
              {
                'is_default' => delivery_address.is_default,
                'prefecture_code' => delivery_address.prefecture_code,
                'prefecture' => delivery_address.prefecture.name,
                'zip_code' => delivery_address.zip_code,
                'city' => delivery_address.city,
                'address_1' => delivery_address.address_1,
                'address_2' => delivery_address.address_2,
                'contact_tel' => delivery_address.contact_tel,
              },
            ],
          })
        end
      end
    end

    context 'when user is not logged in' do
      it 'returns http status 401' do
        is_expected.to eq 401
      end
    end

    context 'when token is expired' do
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: current_user.id,
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

    context 'when current user donot have userinfo scopes' do
      let(:oauth_token) {
        OauthAccessToken.create!(
          tenant_id: current_tenant.id,
          application_id: oauth_application.id,
          resource_owner_id: current_user.id,
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
