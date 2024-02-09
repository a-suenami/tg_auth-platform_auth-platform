# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
Doorkeeper::OpenidConnect.configure do
  issuer do |_resource_owner, _application|
    'auth-platform'
  end

  # TODO: OpenID Connect用のPrivateキーは環境変数に含めるようにする
  # とりあえず開発用キーをセット　使いまわさないこと
  signing_key Settings.doorkeeper.openid_connect.signing_key

  # rubocop:disable Naming/VariableNumber
  signing_algorithm :es256
  # rubocop:enable Naming/VariableNumber

  subject_types_supported [:public]

  resource_owner_from_access_token do |access_token|
    User.find(access_token.resource_owner_id)
  end

  auth_time_from_resource_owner do |resource_owner|
    # Example implementation:
    # resource_owner.current_sign_in_at
  end

  reauthenticate_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # sign_out resource_owner
    # redirect_to new_user_session_url
  end

  # Depending on your configuration, a DoubleRenderError could be raised
  # if render/redirect_to is called at some point before this callback is executed.
  # To avoid the DoubleRenderError, you could add these two lines at the beginning
  #  of this callback: (Reference: https://github.com/rails/rails/issues/25106)
  #   self.response_body = nil
  #   @_response_body = nil
  select_account_for_resource_owner do |resource_owner, return_to|
    # Example implementation:
    # store_location_for resource_owner, return_to
    # redirect_to account_select_url
  end

  subject do |resource_owner, _application|
    # Example implementation:
    resource_owner.id

    # or if you need pairwise subject identifier, implement like below:
    # Digest::SHA256.hexdigest("#{resource_owner.id}#{URI.parse(application.redirect_uri).host}#{'your_secret_salt'}")
  end

  # Protocol to use when generating URIs for the discovery endpoint,
  # for example if you also use HTTPS in development
  # protocol do
  #   :https
  # end

  # Expiration time on or after which the ID Token MUST NOT be accepted for processing. (default 120 seconds).
  # expiration 600

  # Example claims:
  claims do
    normal_claim :tenant_id, response: :id_token do |resource_owner|
      resource_owner&.tenant_id
    end

    claim :sms_authenticated, response: :id_token, scope: :sms2fa do |_resource_owner|
      true
    end

    claim :user, response: :id_token do |resource_owner, scope|
      json = {}
      profile_json = {}
      contact_address_json = {}

      json[:uid] = resource_owner.id if scope.exists?(:uid)
      json[:email] = resource_owner.email if scope.exists?(:email)
      json[:phone_number] = resource_owner.phone_number if scope.exists?(:phone_number)
      json[:enabled] = resource_owner.enabled
      json[:email_verified] = resource_owner.email_verified if scope.exists?(:email)
      json[:sms_verified] = resource_owner.sms_verified if scope.exists?(:phone_number)
      if scope.exists?(:name)
        profile_json[:first_name] = resource_owner.user_profile&.first_name
        profile_json[:last_name] = resource_owner.user_profile&.last_name
        profile_json[:first_name_kana] = resource_owner.user_profile&.first_name_kana
        profile_json[:last_name_kana] = resource_owner.user_profile&.last_name_kana
      end
      if scope.exists?(:profile)
        profile_json[:birth_date] = resource_owner.user_profile&.birth_date
        profile_json[:gender] = resource_owner.user_profile&.gender
        contact_address_json[:prefecture_code] = resource_owner.contact_address&.prefecture_code_jis
        contact_address_json[:prefecture] = resource_owner.contact_address&.prefecture&.name
      end
      if scope.exists?(:contact)
        contact_address_json[:prefecture_code] = resource_owner.contact_address&.prefecture_code_jis
        contact_address_json[:prefecture] = resource_owner.contact_address&.prefecture&.name
        contact_address_json[:zip_code] = resource_owner.contact_address&.zip_code
        contact_address_json[:city] = resource_owner.contact_address&.city
        contact_address_json[:street] = resource_owner.contact_address&.street
        contact_address_json[:building] = resource_owner.contact_address&.building
        contact_address_json[:phone_number] = resource_owner.contact_address&.phone_number
        contact_address_json[:country_code] = resource_owner.contact_address&.country_code
      end
      if scope.exists?(:delivery_address)
        json[:delivery_addresses] = resource_owner.delivery_addresses.map do |address|
          address_json = {}
          address_json[:is_default] = address&.is_default
          address_json[:prefecture_code] = address&.prefecture_code_jis
          address_json[:prefecture] = address&.prefecture&.name
          address_json[:zip_code] = address&.zip_code
          address_json[:city] = address&.city
          address_json[:street] = address&.street
          address_json[:building] = address&.building
          address_json[:phone_number] = address&.phone_number
          address_json[:country_code] = address&.country_code
          address_json
        end
      end

      json[:profile] = profile_json if scope.exists?(:name) || scope.exists?(:profile)
      json[:contact_address] = contact_address_json if scope.exists?(:profile) || scope.exists?(:contact)

      json
    end
  end
end
# rubocop:enable Metrics/BlockLength
