module SecureCookieStoreUseable
  extend ActiveSupport::Concern

  included do
    before_action :init_session
  end

  def init_session
    @session = SecureCookieStore.new(session)
  end

  def cookie_session
    @session
  end
end
