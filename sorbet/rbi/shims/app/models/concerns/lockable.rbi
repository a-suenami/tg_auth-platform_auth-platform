# typed: strict

# ==============================================================================
# sorbet - rbi - shims - app - models - concerns - lockable
# ==============================================================================
module Lockable
  extend ActiveSupport::Concern
  extend T::Sig

  sig { params(failed_attempts: Integer).returns(Integer) }
  def failed_attempts=(failed_attempts); end

  sig { returns(T.nilable(Integer)) }
  def failed_attempts; end

  sig { params(lock_expired_at: T.nilable(Date)).returns(Date) }
  def lock_expired_at=(lock_expired_at); end

  sig { returns(T.nilable(Date)) }
  def lock_expired_at; end

  sig { params(unlock_token: T.nilable(String)).returns(String) }
  def unlock_token=(unlock_token); end

  sig { returns(T.nilable(String)) }
  def unlock_token; end
end

