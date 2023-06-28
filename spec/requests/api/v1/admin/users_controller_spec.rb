# typed: false

RSpec.describe '[ Admin Users API ]' do
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
          'Content-Type': 'application/json',
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
            'delivery_addresses' => [
              {
                'is_default' => delivery_address.is_default,
                'prefecture_code' => delivery_address.prefecture_code,
                'prefecture' => delivery_address.prefecture.name,
                'zip_code' => delivery_address.zip_code,
                'city' => delivery_address.city,
                'street' => delivery_address.street,
                'building_name' => delivery_address.building_name,
                'country_code'=>'JP',
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
              'street' => contact_address.street,
              'building_name' => contact_address.building_name,
              'country_code'=>'JP',
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
