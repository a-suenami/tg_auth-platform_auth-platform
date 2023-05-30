# typed: false

RSpec.describe '[ Password API ]' do
  describe 'GET /api/v1/internal/me/profile' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }
    let(:user_1_profile) {
      create(:user_profile, tenant_id: current_tenant.id, user_id: user_1.id)
    }
    let(:user_1_contact_address) {
      create(:contact_address, tenant_id: current_tenant.id, user_id: user_1.id)
    }

    before do
      user_1
      user_1_profile
      user_1_contact_address
    end

    context 'when no session' do
      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      let(:session_mock) {
        instance_double(ActionDispatch::Request::Session)
      }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
        allow(session_mock).to receive(:[]).and_return(user_1.id)
        allow(session_mock).to receive(:key?).and_return(false)
        allow(session_mock).to receive(:loaded?).and_return(false)
        allow(session_mock).to receive(:enabled?).and_return(true)
        allow(session_mock).to receive(:[]=).and_return(nil)
      end

      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['profile']['first_name']).to eq('太郎')
        expect(body_hash['profile']['last_name']).to eq('山田')
        expect(body_hash['profile']['first_name_kana']).to eq('タロウ')
        expect(body_hash['profile']['last_name_kana']).to eq('ヤマダ')
        expect(body_hash['profile']['birth_date']).to eq('1990-01-01')
        expect(body_hash['profile']['gender']).to eq('male')
        expect(body_hash['contact_address']['prefecture_code']).to eq(13)
        expect(body_hash['contact_address']['prefecture']).to eq('東京都')
        expect(body_hash['contact_address']['zip_code']).to eq('155-0033')
        expect(body_hash['contact_address']['city']).to eq('世田谷区代田')
        expect(body_hash['contact_address']['address_1']).to eq('1-1-1')
        expect(body_hash['contact_address']['address_2']).to eq('代田アモーレ 101号室')
      end
    end
  end

  describe 'POST /api/v1/internal/me/profile' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    before do
      user_1
    end

    context 'when no session' do
      let(:params) {
        {
          user: {
            user_profile_attributes: {
              first_name: '2',
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
              address_1: '５丁目１３−８',
              address_2: '代田フラット101',
            },
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      let(:session_mock) {
        instance_double(ActionDispatch::Request::Session)
      }
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
              address_1: '５丁目１３−８',
              address_2: '代田フラット101',
            },
          },
        }
      }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
        allow(session_mock).to receive(:[]).and_return(user_1.id)
        allow(session_mock).to receive(:key?).and_return(false)
        allow(session_mock).to receive(:loaded?).and_return(false)
        allow(session_mock).to receive(:enabled?).and_return(true)
        allow(session_mock).to receive(:[]=).and_return(nil)
      end


      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['profile']['first_name']).to eq('太郎')
        expect(body_hash['profile']['last_name']).to eq('山田')
        expect(body_hash['profile']['first_name_kana']).to eq('タロウ')
        expect(body_hash['profile']['last_name_kana']).to eq('ヤマダ')
        expect(body_hash['profile']['birth_date']).to eq('2000-01-11')
        expect(body_hash['profile']['gender']).to eq('male')
        expect(body_hash['contact_address']['prefecture_code']).to eq(13)
        expect(body_hash['contact_address']['prefecture']).to eq('東京都')
        expect(body_hash['contact_address']['zip_code']).to eq('155-0033')
        expect(body_hash['contact_address']['city']).to eq('世田谷区代田')
        expect(body_hash['contact_address']['address_1']).to eq('５丁目１３−８')
        expect(body_hash['contact_address']['address_2']).to eq('代田フラット101')
      end
    end
  end

  describe 'PUT /api/v1/internal/me/profile' do
    let(:user_1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password_digest: nil)
    }

    before do
      user_1
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
              address_1: '５丁目１３−８',
              address_2: '代田フラット101',
            },
          },
        }
      }

      it 'returns 401' do
        is_expected.to eq 401
      end
    end

    context 'when present session' do
      let(:session_mock) {
        instance_double(ActionDispatch::Request::Session)
      }
      let(:params) {
        {
          user: {
            user_profile_attributes: {
              first_name: '太郎2',
              last_name: '山田2',
              first_name_kana: 'タロウツー',
              last_name_kana: 'ヤマダツー',
              birth_date: '2010-01-11',
              gender: 'male',
            },
            contact_address_attributes: {
              zip_code: '155-0031',
              prefecture_code: '13',
              city: '世田谷区北沢',
              address_1: '1丁目1-1',
              address_2: 'グレートオウル北沢101',
            },
          },
        }
      }

      before do
        allow_any_instance_of(ActionDispatch::Request).to receive(:session).and_return(session_mock)
        allow(session_mock).to receive(:[]).and_return(user_1.id)
        allow(session_mock).to receive(:key?).and_return(false)
        allow(session_mock).to receive(:loaded?).and_return(false)
        allow(session_mock).to receive(:enabled?).and_return(true)
        allow(session_mock).to receive(:[]=).and_return(nil)
      end


      it 'returns 200' do
        is_expected.to eq 200
        expect(body_hash['profile']['first_name']).to eq('太郎2')
        expect(body_hash['profile']['last_name']).to eq('山田2')
        expect(body_hash['profile']['first_name_kana']).to eq('タロウツー')
        expect(body_hash['profile']['last_name_kana']).to eq('ヤマダツー')
        expect(body_hash['profile']['birth_date']).to eq('2010-01-11')
        expect(body_hash['profile']['gender']).to eq('male')
        expect(body_hash['contact_address']['prefecture_code']).to eq(13)
        expect(body_hash['contact_address']['prefecture']).to eq('東京都')
        expect(body_hash['contact_address']['zip_code']).to eq('155-0031')
        expect(body_hash['contact_address']['city']).to eq('世田谷区北沢')
        expect(body_hash['contact_address']['address_1']).to eq('1丁目1-1')
        expect(body_hash['contact_address']['address_2']).to eq('グレートオウル北沢101')
      end
    end
  end
end
