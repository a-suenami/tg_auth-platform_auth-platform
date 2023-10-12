# frozen_string_literal: true

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
    normal_claim :email, response: :id_token, scope: :email do |resource_owner|
      resource_owner&.email
    end
    normal_claim :name, response: :id_token, scope: :name do |resource_owner|
      "#{resource_owner&.user_profile&.last_name} #{resource_owner&.user_profile&.first_name}"
    end
    normal_claim :given_name, response: :id_token, scope: :name do |resource_owner|
      resource_owner&.user_profile&.first_name
    end
    normal_claim :family_name, response: :id_token, scope: :name do |resource_owner|
      resource_owner&.user_profile&.last_name
    end
    normal_claim :birthdate, response: :id_token, scope: :profile do |resource_owner|
      resource_owner&.user_profile&.birth_date
    end
    normal_claim :gender, response: :id_token, scope: :profile do |resource_owner|
      resource_owner&.user_profile&.gender
    end
    normal_claim :tenant_id, response: :id_token do |resource_owner|
      resource_owner&.tenant_id
    end
  end
end
