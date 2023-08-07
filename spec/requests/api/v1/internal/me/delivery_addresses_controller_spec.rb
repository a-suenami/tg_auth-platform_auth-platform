# typed: false

RSpec.describe '[ DeliveryAddresses API ]' do
  describe 'GET /api/v1/internal/me/delivery_addresses' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    include_context 'current user session is present'

    before do
      current_user
      current_user_profile
      current_user_contact_address
      current_user_delivery_addresses
    end

    context 'when present delivery_addresses' do
      it 'returns 200' do
        is_expected.to eq 200
        expect(body_array[0]['zip_code']).to eq('155-0033')
        expect(body_array[0]['prefecture_code']).to eq('13')
        expect(body_array[0]['prefecture']).to eq('東京都')
        expect(body_array[0]['city']).to eq('世田谷区代田')
        expect(body_array[0]['street']).to eq('1-1-1')
        expect(body_array[0]['building']).to eq('代田アモーレ 101号室')
        expect(body_array[0]['contact_tel']).to eq('090-1234-5678')
      end
    end
  end

  describe 'GET /api/v1/internal/me/delivery_addresses/:id' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_delivery_street) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: current_user.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        street: '1-1-2',
        building: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:current_user_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:id) { current_user_delivery_street.id }

    include_context 'current user session is present'

    before do
      current_user
      current_user_profile
      current_user_contact_address
      current_user_delivery_street
      current_user_delivery_addresses
    end

    context 'when present delivery_addresses' do
      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['zip_code']).to eq('155-0031')
        expect(body_hash['prefecture_code']).to eq('13')
        expect(body_hash['prefecture']).to eq('東京都')
        expect(body_hash['city']).to eq('世田谷区北沢')
        expect(body_hash['street']).to eq('1-1-2')
        expect(body_hash['building']).to eq('北沢アモーレ 101号室')
        expect(body_hash['contact_tel']).to eq('080-1234-5678')
      end
    end
  end

  describe 'POST /api/v1/internal/me/delivery_addresses' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    include_context 'current user session is present'

    before do
      current_user
      current_user_profile
      current_user_contact_address
      current_user_delivery_addresses
    end

    context 'when params vaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: '1550031',
            prefecture_code: '13',
            city: '世田谷区北沢',
            street: '1-1-2',
            building: '北沢アモーレ 101号室',
            contact_tel: '080-1234-5678',
          },
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['zip_code']).to eq('155-0031')
        expect(body_hash['prefecture_code']).to eq('13')
        expect(body_hash['prefecture']).to eq('東京都')
        expect(body_hash['city']).to eq('世田谷区北沢')
        expect(body_hash['street']).to eq('1-1-2')
        expect(body_hash['building']).to eq('北沢アモーレ 101号室')
        expect(body_hash['contact_tel']).to eq('080-1234-5678')
      end
    end

    context 'when params invaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: nil,
            prefecture_code: nil,
            city: nil,
            street: nil,
            building: nil,
            contact_tel: nil,
          },
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end
  end

  describe 'PUT /api/v1/internal/me/delivery_addresses/:id' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    let(:current_user_delivery_street) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: current_user.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        street: '1-1-2',
        building: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:current_user_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:id) { current_user_delivery_street.id }

    include_context 'current user session is present'

    before do
      current_user
      current_user_profile
      current_user_contact_address
      current_user_delivery_addresses
    end

    context 'when params vaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: '105-0011',
            prefecture_code: '13',
            city: '東京都港区芝公園',
            street: '４丁目２−８',
            building: '東京タワー 2F',
            contact_tel: '080-1234-1234',
          },
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['zip_code']).to eq('105-0011')
        expect(body_hash['prefecture_code']).to eq('13')
        expect(body_hash['prefecture']).to eq('東京都')
        expect(body_hash['city']).to eq('東京都港区芝公園')
        expect(body_hash['street']).to eq('４丁目２−８')
        expect(body_hash['building']).to eq('東京タワー 2F')
        expect(body_hash['contact_tel']).to eq('080-1234-1234')
      end
    end

    context 'when params invaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: nil,
            prefecture_code: nil,
            city: nil,
            street: nil,
            building: nil,
            contact_tel: nil,
          },
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end
  end


  describe 'DELETE /api/v1/internal/me/delivery_addresses/:id' do
    let(:current_user) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:current_user_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:current_user_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: current_user.id)
    }

    let(:current_user_delivery_street) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: current_user.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        street: '1-1-2',
        building: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:current_user_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: current_user.id)
    }
    let(:id) { current_user_delivery_street.id }

    include_context 'current user session is present'

    before do
      current_user
      current_user_profile
      current_user_contact_address
      current_user_delivery_addresses
    end

    context 'when params vaild' do
      it 'returns 204' do
        expect(DeliveryAddress.find_by(id: current_user_delivery_street.id)).not_to be_nil
        is_expected.to eq 204
        expect(DeliveryAddress.find_by(id: current_user_delivery_street.id)).to be_nil
      end
    end
  end
end
