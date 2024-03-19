# typed: false

module Auth0Connectable
  extend ActiveSupport::Concern
  extend T::Sig

  def auth0_client
    @auth0_client ||= T.let(nil, T.nilable(Auth0Client))
    @auth0_client ||= Auth0Client.new(
      client_id: Settings.ruler.auth0.auth0_client_id,
      client_secret: Settings.ruler.auth0.auth0_client_secret,
      domain: Settings.ruler.auth0.auth0_domain,
      api_version: 2,
      timeout: 10,
    )
  end

  def create_auth0_user(password = nil)
    return if Rails.env.test?

    if password.blank?
      password = random_password
    end

    auth0_client.create_user(
      Settings.ruler.auth0.username_password_connection_name,
      {
        email: self.email,
        password:,
        email_verified: false,
        user_id: self.id,
      },
    )
  end

  def random_password
    symbols = ['!', '@', '#', '$', '%', '^', '&', '*']
    SecureRandom.alphanumeric(10) + ['a'..'z'].sample(1).join + ['0'..'9'].sample(1).join + ['A'..'Z'].sample(1).join + symbols.sample(1).join
  end
end
