module SessionKeyUseable
  extend ActiveSupport::Concern

  def init_session_key(identify_key)
    session_key = SecureRandom.hex(64)
    Redis.some.set("session_key_#{Tenant.current.id}_#{identify_key}", session_key)
    # TODO: セッションキーの有効期限を考える
    Redis.some.expire("session_key_#{Tenant.current.id}_#{identify_key}", 12.hours)
    session_key
  end

  def verify_session_key(identify_key, session_key)
    return false if session_key.blank?

    session_key == Redis.some.get("session_key_#{Tenant.current.id}_#{identify_key}")
  end

  def delete_session_key(identify_key)
    Redis.some.del("session_key_#{Tenant.current.id}_#{identify_key}")
  end

  def session_key_authenticate
    session_key = params[:session_key]
    identify_key = params[:user_id]
    return if verify_session_key(identify_key, session_key)

    handle_401 error_details: ['failed verify session key']
  end
end
