# typed: false

RSpec.describe '[ Registrations API ]' do
  describe 'POST /api/v1/authentication/registrations/send_verification_email' do
    let!(:user1) {
      create(:user, tenant_id: current_tenant.id, email: 'test-user1@example.com', password: "test-user1password")
    }

    let!(:email_template) {
      create(:email_template,
        tenant_id: current_tenant.id,
        name: 'メールテンプレート名',
        template_type: "email_address_verification",
        subject: 'email確認のお願い',
        body: <<~TEXT
          <p>認証コードは以下です</p>
          <p>{{ email_verification_code }}</p>
        TEXT
      )
    }
    let(:blastengine_mock) {
      instance_double('Blastengine::API')
    }

    before do
      allow(Blastengine::API).to receive(:new).and_return(blastengine_mock)
      allow(blastengine_mock).to receive(:send_email).and_return({
        "delivery_id": 1
      })
    end

    context 'when email invaild' do
      let(:params) {
        {
          email: 'hogehoge',
        }
      }

      it 'returns 400' do
        is_expected.to eq 400
      end
    end

    context 'when email vaild' do
      let(:params) {
        {
          email: 'test-user1@example.com',
        }
      }

      it 'returns 200' do
        is_expected.to eq 200
        expect(blastengine_mock).to have_received(:send_email)
      end
    end
  end

  # describe 'POST /api/v1/authentication/registrations/verify_email' do
  # end
end
