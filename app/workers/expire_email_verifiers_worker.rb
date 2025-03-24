# typed: strict

class ExpireEmailVerifiersWorker < ApplicationController
  extend T::Sig
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority, retry: 3

  sig { void }
  def perform
    Users::EmailVerifier.where('expired_at < ?', Time.zone.now).delete_all
  end
end
