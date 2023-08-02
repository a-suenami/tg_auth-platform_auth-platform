# typed: strict

class SecureCookieStore
  extend T::Sig

  sig { params(session: T.untyped).void }
  def initialize(session)
    @session = session
  end

  sig { params(key: Symbol).returns(T.untyped) }
  def [](key)
    session_clear if check_expires(key)
    @session[key]
  end

  sig { params(key: Symbol, value: T.untyped).void }
  def []=(key, value)
    set_expires(key)
    @session[key] = value
  end

  sig { void }
  def session_clear
    @session.clear
  end

  private

  sig { params(key: Symbol).returns(T::Boolean) }
  def check_expires(key)
    # TODO: 判定結果をキャッシュし、繰り返し呼ばれないようにする
    return true if @session[:"#{key}_expired_at"].nil?

    @session[:"#{key}_expired_at"] < Time.zone.now
  end

  sig { params(key: Symbol).void }
  def set_expires(key)
    @session[:"#{key}_expired_at"] = 1.week.from_now
  end
end
