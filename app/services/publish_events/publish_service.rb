# typed: false

module PublishEvents
  class PublishService < ::BaseService
    def execute(user:, action_code:)
      return false if Settings.aws&.region.blank?
      return false if Settings.aws&.event_bus_name.blank?

      enable_applications = OauthApplication.where(tenant_id: user.tenant_id, enable_push_event: true)
      return false if enable_applications.blank?

      enable_applications.each do |application|
        put_events(user:, action_code:, application:)
      end
    end

    private

    def put_events(user:, action_code:, application:)
      aws_event_bridge_client.put_events({
        entries: [
          {
            source: 'id-platform.twogate',
            detail_type: 'Id Platform User',
            detail: {
              tenant_id: user.tenant_id,
              user_id: user.id,
              oauth_application_id: application.id,
              action_code:,
              submitted_at: Time.zone.now.to_s,
              user: user_json(user:), # TODO: applicationのscopeによって含める項目を増減させる
            }.to_json,
            event_bus_name: Settings.aws.event_bus_name,
          },
        ],
      })
    end

    # ぼっち演算子を使った書き方なら、視認性に問題ないと判断し無効にする
    # rubocop:disable Metrics/CyclomaticComplexity
    def user_json(user:)
      {
        uid: user.id,
        email: user.email,
        phone_number: user.phone_number,
        profile: {
          first_name: user.user_profile&.first_name,
          last_name: user.user_profile&.last_name,
          first_name_kana: user.user_profile&.first_name_kana,
          last_name_kana: user.user_profile&.last_name_kana,
          birth_date: user.user_profile&.birth_date,
          gender: user.user_profile&.gender,
        },
        contact_address: {
          prefecture_code: user.contact_address&.prefecture_code_jis,
          prefecture: user.contact_address&.prefecture&.name,
          zip_code: user.contact_address&.zip_code,
          city: user.contact_address&.city,
          street: user.contact_address&.street,
          building: user.contact_address&.building,
          country_code: user.contact_address&.country_code,
          phone_number: user.contact_address&.phone_number,
        },
        delivery_addresses: user.delivery_addresses.map do |delivery_address|
          {
            id: delivery_address.id,
            is_default: delivery_address.is_default,
            prefecture_code: delivery_address.prefecture_code_jis,
            prefecture: delivery_address.prefecture&.name,
            zip_code: delivery_address.zip_code,
            city: delivery_address.city,
            street: delivery_address.street,
            building: delivery_address.building,
            country_code: delivery_address.country_code,
            phone_number: delivery_address.phone_number,
          }
        end,
      }
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # sig { returns(Aws::EventBridge::Client) }
    def aws_event_bridge_client
      @aws_event_bridge_client ||= ::Aws::EventBridge::Client.new(
        region: Settings.aws.region,
        credentials:,
      )
    end

    # sig { returns(T.any(Aws::Credentials, Aws::ECSCredentials)) }
    def credentials
      if Settings.aws.access_key_id
        ::Aws::Credentials.new(Settings.aws.access_key_id, Settings.aws.secret_access_key)
      else
        ::Aws::ECSCredentials.new
      end
    end
  end
end
