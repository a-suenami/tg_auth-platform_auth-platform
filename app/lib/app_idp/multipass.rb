# typed: false

# rubocop:disable Naming/VariableNumber
module AppIdp
  class Multipass
    def generate(multipass_store, user, return_to, remote_ip)
      # return_toの取得
      return_to = validate_return_to(return_to, multipass_store)

      # 追加データ
      data = {}
      data['return_to'] = return_to
      data['remote_ip'] = remote_ip

      # メールアドレス変更処理
      check_and_update_email(user, multipass_store)

      # Multipassに渡すデータ生成
      customer_data = convert_multipass_customer_data(data, user)

      generate_multipass_url(customer_data, multipass_store)
    end

    private

    def safe_parse_url(url)
      return nil if url.blank?

      # 1. 非ASCII文字が含まれている場合は%エンコード
      encoded_url = encode_non_ascii(url)
      # 2. パースして返す
      begin
        URI.parse(encoded_url)
      rescue URI::InvalidURIError, URI::InvalidComponentError
        # 3. パースに失敗した場合は、無効なURLとしてnilを返す
        nil
      end
    end

    # 非ASCII文字をエンコードする
    def encode_non_ascii(url)
      return url if url.ascii_only?

      url.each_char.map { |char|
        # ASCII（0x00〜0x7F）の範囲かどうかをチェック
        char.ascii_only? ? char : CGI.escape(char)
      }.join
    end

    # return_toのホストチェック
    def validate_return_to(return_to, multipass_store)
      uri = safe_parse_url(return_to)

      # URLが無効な場合は、デフォルトのreturn_toを返す
      return nil if uri.nil?

      # ホストがない -> 相対パスとみなす、フォーマットが正しいか確認
      return uri.to_s if uri.host.nil? && uri.to_s.match?(%r{\A/[a-zA-Z0-9._~!$&'()*+,;=:@/?#%-]*\z})
      # ホストがある -> ホストがマルチパスストアのホストと一致するか確認
      return uri.to_s if uri.host == URI.parse(multipass_store.store_url).host

      # それ以外は無効なURLとしてnilを返す
      nil
    end

    def check_and_update_email(user, multipass_store)
      shopify_customer = user.shopify_customers.find_by(multipass_store:)

      if shopify_customer.nil?
        handle_new_user(user, multipass_store)
      else
        handle_existing_user(user, shopify_customer, multipass_store)
      end
    end

    # 新規ユーザーの処理
    def handle_new_user(user, multipass_store)
      ActiveRecord::Base.transaction do
        email_duplicated_shopify_customer = ShopifyRecord::Customer.find_by(multipass_store:, email: user.email)

        if email_duplicated_shopify_customer.present?
          mask_shopify_customer_email(email_duplicated_shopify_customer, multipass_store)
        end
      end
    end

    # 既存ユーザーの処理
    def handle_existing_user(user, shopify_customer, multipass_store)
      ActiveRecord::Base.transaction do
        if shopify_customer.email != user.email
          # 変更後のemailアドレスが過去にShopifyに連携されていた可能性を一応考慮
          email_duplicated_shopify_customer = ShopifyRecord::Customer.find_by(multipass_store:, email: user.email)
          if email_duplicated_shopify_customer.present?
            mask_shopify_customer_email(email_duplicated_shopify_customer, multipass_store)
          end

          update_email(shopify_customer.remote_id, shopify_customer.email, multipass_store, user.email)
        end
      end
    end

    # ダミーのメールアドレスを生成
    def generate_dummy_email(user_id)
      "disabled+#{user_id}@disabled.twogate-idp.com"
    end

    def mask_shopify_customer_email(shopify_customer, multipass_store)
      dummy_email = generate_dummy_email(shopify_customer.user.id)
      update_email(shopify_customer.remote_id, shopify_customer.email, multipass_store, dummy_email)
    end

    # メールアドレスの更新
    def update_email(remote_id, current_email, multipass_store, new_email = nil)
      customer_id = "gid://shopify/Customer/#{remote_id}"
      client = AppShopify::Customer.new(shopify_record_multipass_store: multipass_store)
      client.update_email(customer_id, new_email) if current_email && current_email != new_email
    end

    def convert_multipass_customer_data(data, user)
      payload = {
        identifier: user.id,
        email: user.email,
        last_name: user.user_profile.last_name,
        first_name: user.user_profile.first_name,
        return_to: data['return_to'],
        remote_ip: data['remote_ip'],
      }

      payload[:addresses] = convert_multipass_customer_address(user)

      payload
    end


    def convert_multipass_customer_address(user)
      return [] if user.nil?
      return [] if user.contact_address.blank? || user.contact_address.country_code != 'JP'

      # 一旦contact addressのみを対象とする
      addresses = []
      addresses << {
        last_name: user.user_profile.last_name,
        first_name: user.user_profile.first_name,
        zip: user.contact_address.zip_code,
        province: user.contact_address.prefecture.name_r,
        city: user.contact_address.city,
        address1: user.contact_address.street,
        address2: user.contact_address.building,
        country: 'Japan',
        phone: user.contact_address.phone_number,
      }
      addresses
    end


    def generate_multipass_url(customer_data, multipass_store)
      token = ShopifyMultipass.new(multipass_store.multipass_secret).generate_token(customer_data)

      "#{multipass_store.store_url}/account/login/multipass/#{token}"
    end
  end
end
# rubocop:enable Naming/VariableNumber
