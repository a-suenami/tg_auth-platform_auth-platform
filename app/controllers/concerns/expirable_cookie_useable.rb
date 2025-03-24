# typed: false

module ExpirableCookieUseable
  extend ActiveSupport::Concern

  included do
    before_action :init_session
  end

  def init_session
    @session = ExpirableCookie.new(session)
  end

  def cookie_session
    @session
  end
end
