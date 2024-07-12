# typed: false

module Auth0Connectable
  extend ActiveSupport::Concern
  extend T::Sig

  def auth0_client
    @auth0_client ||= T.let(nil, T.nilable(Auth0Client))
    @auth0_client ||= Auth0Client.new(
      client_id: auth0_client_id,
      client_secret: auth0_client_secret,
      domain: auth0_domain,
      api_version: 2,
      timeout: 10,
    )
  end

  def create_auth0_user!(password = nil)
    return if Rails.env.test?

    if password.blank?
      password = random_password
    end

    # すでにauth0側にアカウントが存在する場合
    auth0_user_id = get_auth0_user_id_by_email(self.email)
    if auth0_user_id.present?
      self.uid = auth0_user_id
    else
      auth0_response = auth0_client.create_user(
        auth0_connection_name,
        {
          email: self.email,
          password:,
          email_verified: false,
        },
      )
      self.uid = auth0_response['user_id']
    end
    self.save!
  end

  def random_password
    symbols = ['!', '@', '#', '$', '%', '^', '&', '*']
    SecureRandom.alphanumeric(10) + ['a'..'z'].sample(1).join + ['0'..'9'].sample(1).join + ['A'..'Z'].sample(1).join + symbols.sample(1).join
  end

  def get_auth0_user_id_by_email(email)
    query = "email:\"#{email}\" AND identities.connection:\"#{auth0_connection_name}\""
    options = {
      fields: 'user_id',
      include_fields: true,
      q: query,
      search_engine: 'v3',
    }

    users = auth0_client.users(options)
    return nil if users.blank?

    users[0]['user_id']
  end

  private

  def auth0_client_id
    raise NotImplementedError 'auth0_client_id method must be implemented in the class'
  end

  def auth0_client_secret
    raise NotImplementedError 'auth0_client_secret method must be implemented in the class'
  end

  def auth0_domain
    raise NotImplementedError 'auth0_domain method must be implemented in the class'
  end

  def auth0_connection_name
    raise NotImplementedError 'auth0_connection_name method must be implemented in the class'
  end
end
