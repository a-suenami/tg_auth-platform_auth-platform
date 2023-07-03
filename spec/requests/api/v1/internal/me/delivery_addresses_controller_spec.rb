# typed: false

RSpec.describe '[ DeliveryAddresses API ]' do
  describe 'GET /api/v1/internal/me/delivery_addresses' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
      user_1_delivery_addresses
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when present delivery_addresses' do
      it 'returns 200' do
        is_expected.to eq 200
        expect(body_array[0]['zip_code']).to eq('155-0033')
        expect(body_array[0]['prefecture_code']).to eq('13')
        expect(body_array[0]['prefecture']).to eq('東京都')
        expect(body_array[0]['city']).to eq('世田谷区代田')
        expect(body_array[0]['address_1']).to eq('1-1-1')
        expect(body_array[0]['address_2']).to eq('代田アモーレ 101号室')
        expect(body_array[0]['contact_tel']).to eq('090-1234-5678')
      end
    end
  end

  describe 'GET /api/v1/internal/me/delivery_addresses/:id' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_delivery_address_1) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: user_1.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        address_1: '1-1-2',
        address_2: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:user_1_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:id) { user_1_delivery_address_1.id }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
      user_1_delivery_address_1
      user_1_delivery_addresses
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when present delivery_addresses' do
      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['zip_code']).to eq('155-0031')
        expect(body_hash['prefecture_code']).to eq('13')
        expect(body_hash['prefecture']).to eq('東京都')
        expect(body_hash['city']).to eq('世田谷区北沢')
        expect(body_hash['address_1']).to eq('1-1-2')
        expect(body_hash['address_2']).to eq('北沢アモーレ 101号室')
        expect(body_hash['contact_tel']).to eq('080-1234-5678')
      end
    end
  end

  describe 'POST /api/v1/internal/me/delivery_addresses' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
      user_1_delivery_addresses
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when params vaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: '1550031',
            prefecture_code: '13',
            city: '世田谷区北沢',
            address_1: '1-1-2',
            address_2: '北沢アモーレ 101号室',
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
        expect(body_hash['address_1']).to eq('1-1-2')
        expect(body_hash['address_2']).to eq('北沢アモーレ 101号室')
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
            address_1: nil,
            address_2: nil,
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
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    let(:user_1_delivery_address_1) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: user_1.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        address_1: '1-1-2',
        address_2: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:user_1_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:id) { user_1_delivery_address_1.id }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
      user_1_delivery_addresses
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when params vaild' do
      let(:params) {
        {
          delivery_addresses: {
            zip_code: '105-0011',
            prefecture_code: '13',
            city: '東京都港区芝公園',
            address_1: '４丁目２−８',
            address_2: '東京タワー 2F',
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
        expect(body_hash['address_1']).to eq('４丁目２−８')
        expect(body_hash['address_2']).to eq('東京タワー 2F')
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
            address_1: nil,
            address_2: nil,
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
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    let(:user_1_delivery_address_1) {
      create(:delivery_address,
        tenant_id: current_tenant.id,
        user_id: user_1.id,
        is_default: 'true',
        zip_code: '1550031',
        prefecture_code: '13',
        city: '世田谷区北沢',
        address_1: '1-1-2',
        address_2: '北沢アモーレ 101号室',
        contact_tel: '080-1234-5678',)
    }
    let(:user_1_delivery_addresses) {
      create_list(:delivery_address, 3, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:id) { user_1_delivery_address_1.id }

    let(:session_mock) {
      instance_double(ActionDispatch::Request::Session)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
      user_1_delivery_addresses
      allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
      allow(session_mock).to receive(:[]).and_return(user_1.id)
      allow(session_mock).to receive(:key?).and_return(false)
      allow(session_mock).to receive(:loaded?).and_return(false)
      allow(session_mock).to receive(:enabled?).and_return(true)
      allow(session_mock).to receive(:[]=).and_return(nil)
    end

    context 'when params vaild' do
      it 'returns 204' do
        expect(DeliveryAddress.find_by(id: user_1_delivery_address_1.id)).not_to be_nil
        is_expected.to eq 204
        expect(DeliveryAddress.find_by(id: user_1_delivery_address_1.id)).to be_nil
      end
    end
  end
end
