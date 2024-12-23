# typed: false

class ExpireEmailVerifiersWorker < ApplicationController
  include Sidekiq::Worker
  sidekiq_options queue: :low_priority, retry: 3

  def perform
    Users::EmailVerifier.where('expired_at < ?', Time.zone.now).delete_all
  end
end
