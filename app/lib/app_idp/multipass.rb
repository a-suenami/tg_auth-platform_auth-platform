# typed: false

# rubocop:disable Naming/VariableNumber
module AppIdp
  class Multipass
    def generate(multipass_setting, user, return_to, remote_ip)
      # return_toの取得
      return_to = validate_return_to(return_to, multipass_setting)

      # 追加データ
      data = {}
      data['return_to'] = return_to
      data['remote_ip'] = remote_ip

      # メールアドレス変更処理
      check_and_update_email(user)

      # Multipassに渡すデータ生成
      customer_data = convert_multipass_customer_data(data, user)

      generate_multipass_url(customer_data, multipass_setting)
    end

    private

    # return_toのホストチェック
    def validate_return_to(return_to, multipass_setting)
      uri = URI.parse(return_to || '')

      if !uri.host || uri.host == URI.parse(multipass_setting.store_url).host
        return_to
      end
    end

    def check_and_update_email(user)
      shopify_customer = user.shopify_customer

      if shopify_customer.nil?
        handle_new_user(user)
      else
        handle_existing_user(user, shopify_customer)
      end
    end

    # 新規ユーザーの処理
    def handle_new_user(user)
      ActiveRecord::Base.transaction do
        other_shopify_customer = find_other_customer(user.email)

        if other_shopify_customer.present?
          dummy_email = generate_dummy_email(user.id)
          update_and_disable_email(other_shopify_customer, dummy_email)
        end
      end
    end

    # 既存ユーザーの処理
    def handle_existing_user(user, shopify_customer)
      ActiveRecord::Base.transaction do
        if shopify_customer.email != user.email
          other_shopify_customer = find_other_customer(user.email)

          if other_shopify_customer.present?
            dummy_email = generate_dummy_email(user.id)
            update_and_disable_email(other_shopify_customer, dummy_email)
          end

          update_email(shopify_customer.remote_id, shopify_customer.email, user.email)
        end
      end
    end

    # 他の有効なカスタマーを見つける
    def find_other_customer(email)
      ShopifyRecord::Customer.find_by(email:)
    end

    # ダミーのメールアドレスを生成
    def generate_dummy_email(id)
      "disabled+#{id}_#{[*'A'..'Z', *0..9].sample(4).join}@disabled.extend-twogate-idp.com"
    end

    # 他のアカウントのメールアドレスをダミーアドレスに変更する
    def update_and_disable_email(shopify_customer, dummy_email)
      update_email(shopify_customer.remote_id, shopify_customer.email, dummy_email)
    end

    # メールアドレスの更新
    def update_email(remote_id, current_email, new_email = nil)
      client = AppShopify::Customer.new
      client.update_email(remote_id, new_email) if current_email && current_email != new_email
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


    def generate_multipass_url(customer_data, multipass_setting)
      token = ShopifyMultipass.new(multipass_setting.multipass_secret).generate_token(customer_data)

      "#{multipass_setting.store_url}/account/login/multipass/#{token}"
    end
  end
end
# rubocop:enable Naming/VariableNumber
