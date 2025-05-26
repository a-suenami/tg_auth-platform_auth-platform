# typed: false
# frozen_string_literal: true

require 'openssl'
require 'json'

# URL-safe Base64の正規表現
# A-Z, a-z, 0-9, -, _, = を含む文字列で、=は末尾にのみ出現可能
URLSAFE_BASE64_REGEX = /[A-Za-z0-9_-]+(?:={1,2})?/

RSpec.describe AppIdp::Multipass do
  describe 'AppIdp::Multipass.generate' do
    subject(:multipass_generator) { described_class.new.generate(multipass_store, current_user, return_to, remote_ip) }

    let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
    let(:multipass_store) { create(:shopify_record__multipass_store, tenant_id: current_tenant.id, store_url: 'https://example.com') }
    let(:current_user) { create(:user, tenant_id: current_tenant.id, email: current_email) }
    let(:current_email) { 'test@example.com' }
    let(:user_profile) { create(:user_profile, tenant_id: current_tenant.id, user: current_user) }
    let(:return_to) { 'https://example.com' }
    let(:remote_ip) { '111.111.111.111' }

    let(:app_shopify_customer) { instance_double(AppShopify::Customer) }

    before do
      RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
      # AppShopify::Customer.new.update_emailが呼ばれたかどうかのスパイ
      allow(AppShopify::Customer).to receive(:new).and_return(app_shopify_customer)
      allow(app_shopify_customer).to receive(:update_email).and_return(nil)
      user_profile
    end

    # トークンを復号化してJSONデータを取得するヘルパーメソッド
    def decrypt_token(token)
      # Base64デコード
      decoded = Base64.urlsafe_decode64(token)

      # 最小長さの検証（IV + 最小暗号文 + HMAC）
      expect(decoded.bytesize).to be >= 48 # 16 (IV) + 16 (最小暗号文) + 32 (HMAC)

      # IVと暗号文とHMACの分離
      iv = decoded[0, 16]
      ciphertext = decoded[16...-32]
      hmac = decoded[-32, 32]

      # HMACの検証
      key_material = OpenSSL::Digest.new('sha256').digest(multipass_store.multipass_secret)
      signature_key = key_material[16, 16]
      expected_hmac = OpenSSL::HMAC.digest('sha256', signature_key, decoded[0...-32])
      expect(hmac).to eq(expected_hmac)

      # AES復号化
      cipher = OpenSSL::Cipher.new('aes-128-cbc')
      cipher.decrypt
      cipher.key = key_material[0, 16] # encryption_key
      cipher.iv = iv

      # 復号化してJSONパース
      decrypted = cipher.update(ciphertext) + cipher.final
      JSON.parse(decrypted)
    end

    context 'return_toパラメータの検証' do
      context '正常系' do
        context 'アスキーコードのみのURLの場合' do
          let(:return_to) { 'https://example.com/path/to/page?param=value' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(return_to)
          end
        end

        # パラメータ受け取り時に一度デコードするので、このパターンになる日は元のreturn_toが2回エンコードされていることになる。
        # 不正なreturn_toとして扱い、return_toはnilになる。
        context '全体が%エンコードされているURLの場合' do
          let(:return_to) { 'https%3A%2F%2Fexample.com%2F%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to be_nil
          end
        end

        context 'パスが%エンコードされているURLの場合' do
          let(:return_to) { 'https://example.com/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(return_to)
          end
        end

        context 'クエリが%エンコードされているURLの場合' do
          let(:return_to) { 'https://example.com/path?q=%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(return_to)
          end
        end

        context 'URLに日本語が含まれる場合' do
          let(:return_to) { 'https://example.com/こんにちは' }

          it 'Shopify MultipassのURLが生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(URI::DEFAULT_PARSER.escape(return_to))
          end
        end

        context 'URLのパスに日本語が含まれる場合' do
          let(:return_to) { 'https://example.com/path/こんにちは' }

          it 'Shopify MultipassのURLが生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(URI::DEFAULT_PARSER.escape(return_to))
          end
        end

        context 'URLのクエリに日本語が含まれる場合' do
          let(:return_to) { 'https://example.com/path?q=こんにちは' }

          it 'Shopify MultipassのURLが生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(URI::DEFAULT_PARSER.escape(return_to))
          end
        end

        context 'given relative path' do
          let(:return_to) { '/path/to/page?param=value' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(URI::DEFAULT_PARSER.escape(return_to))
          end
        end

        context 'given relative path with Japanese characters' do
          let(:return_to) { '/path/こんにちは?hoge=日本&fuga=abc' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(URI::DEFAULT_PARSER.escape(return_to))
          end
        end

        context 'given relative path with encoded Japanese characters' do
          let(:return_to) { '/path/%E3%81%93%E3%82%93%E3%81%AB%E3%81%A1%E3%81%AF' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(return_to)
          end
        end

        # /もエンコードされているパターン。パラメータ受け取り時に一度デコードするので、このパターンになる日は元のreturn_toが2回エンコードされていることになる。
        context 'given encoded relative path' do
          let(:return_to) { '%2Fpath%2F%25E3%2581%2593%25E3%2582%2593%25E3%2581%25AB%25E3%2581%25A1%25E3%2581%25AF' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to be_nil
          end
        end

        context 'given segment' do
          let(:return_to) { 'https://example.com/path/to/page#section' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq(return_to)
          end
        end

        context 'given segment with ja' do
          let(:return_to) { 'https://example.com/path/to/日本語#section' }

          it 'Shopify MultipassのURLが正しく生成され、return_toが含まれること' do
            expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
            token = multipass_generator.split('/').last
            expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
            data = decrypt_token(token)
            expect(data['return_to']).to eq('https://example.com/path/to/%E6%97%A5%E6%9C%AC%E8%AA%9E#section') # URI::DEFAULT_PARSER.escapeはフラグメントをエスケープする不具合があるため、固定で設定
          end
        end
      end
    end

    context 'When a new user logs in for the first time' do
      context 'When there is no other customer with the same email address' do
        it 'Shopify MultipassのURLが正しく生成されること' do
          expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
          token = multipass_generator.split('/').last
          expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
          expect(token.length % 4).to eq(0)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end

      context 'When there is another customer with the same email address' do
        let(:other_user) { create(:user, tenant_id: current_tenant.id) }
        let(:other_user_shopify_record__customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: other_user, remote_id: '1234567890123', email: current_user.email, multipass_store:,
store_name: multipass_store.store_name,)
        }

        before do
          other_user
          other_user_shopify_record__customer
        end

        it 'Shopify MultipassのURLが正しく生成されること' do
          expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
          token = multipass_generator.split('/').last
          expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
          expect(token.length % 4).to eq(0)
          # AppShopify::Customer#update_emailが呼ばれること
          expect(app_shopify_customer).to have_received(:update_email).with("gid://shopify/Customer/#{other_user_shopify_record__customer.remote_id}",
"disabled+#{other_user.id}@disabled.twogate-idp.com",)
        end
      end
    end

    context 'When an existing user logs in' do
      let(:current_user_shopify_record__customer) {
        create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: current_email, multipass_store:, store_name: multipass_store.store_name)
      }

      before do
        current_user_shopify_record__customer
      end

      context 'When the email address is not changed' do
        it 'Shopify MultipassのURLが正しく生成されること' do
          expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
          token = multipass_generator.split('/').last
          expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
          expect(token.length % 4).to eq(0)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end

      context 'When the email address is changed' do
        let(:current_email) { 'changed@example.com' }
        let(:current_user_shopify_record__customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: 'old@example.com', multipass_store:,
store_name: multipass_store.store_name,)
        }

        it 'Shopify MultipassのURLが正しく生成されること' do
          expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
          token = multipass_generator.split('/').last
          expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
          expect(token.length % 4).to eq(0)
          # AppShopify::Customer#update_emailが呼ばれること
          expect(app_shopify_customer).to have_received(:update_email).with("gid://shopify/Customer/#{current_user_shopify_record__customer.remote_id}", current_email)
        end
      end

      context 'When other multipass store customer has the same email address' do
        let(:other_multipass_store) { create(:shopify_record__multipass_store, tenant_id: current_tenant.id, store_name: 'other_store_name') }
        let(:other_multipass_store_customer) {
          create(:shopify_record__customer, tenant_id: current_tenant.id, user: current_user, remote_id: '1234567890123', email: current_email, multipass_store:,
store_name: other_multipass_store.store_name,)
        }

        before do
          other_multipass_store
          other_multipass_store_customer
        end

        it 'Shopify MultipassのURLが正しく生成されること' do
          expect(multipass_generator).to match(%r{\A#{multipass_store.store_url}/account/login/multipass/#{URLSAFE_BASE64_REGEX}\z})
          token = multipass_generator.split('/').last
          expect(token).to match(/\A#{URLSAFE_BASE64_REGEX}\z/)
          expect(token.length % 4).to eq(0)
          # AppShopify::Customerが呼ばれないこと
          expect(app_shopify_customer).not_to have_received(:update_email)
        end
      end
    end
  end
end
