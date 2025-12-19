# typed: true
# frozen_string_literal: true

# Sidekiq::Web is loaded via `require 'sidekiq-ent/web'`
# This shim provides type definitions for mounting Sidekiq web UI in routes.
# Reference: https://github.com/sidekiq/sidekiq/wiki/Ent-Web-UI

module Sidekiq
  class Web
    sig { params(block: T.proc.params(env: T::Hash[String, T.untyped], method: String, path: String).returns(T::Boolean)).void }
    def self.authorize(&block); end

    sig { params(env: T::Hash[String, T.untyped]).returns(T::Array[T.untyped]) }
    def self.call(env); end

    sig { returns(T.untyped) }
    def self.app; end

    sig { returns(T.nilable(String)) }
    def self.app_url; end

    sig { params(app_url: T.nilable(String)).void }
    def self.app_url=(app_url); end
  end
end
