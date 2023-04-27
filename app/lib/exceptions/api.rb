# typed: strict

module Exceptions
  module API
    class BaseError < Exceptions::BaseError; end

    class ServerError < BaseError
      sig { returns(T.nilable(String)) }
      attr_accessor :status, :body

      sig { params(status: T.nilable(String), body: T.nilable(String)).void }
      def initialize(status: nil, body: nil)
        @status = T.let(status, T.untyped)
        @body = T.let(body, T.untyped)
      end

      sig { returns(Symbol) }
      def code
        :server_error
      end

      sig { returns(String) }
      def message
        '外部APIがエラーしました'
      end
    end

    class InvalidRequestError < BaseError
      sig { returns(Symbol) }
      def code
        :invalid_request_error
      end

      sig { returns(String) }
      def message
        '不正なリクエストです'
      end
    end

    class RequestLimitError < BaseError
      sig { returns(Symbol) }
      def code
        :request_limit_error
      end

      sig { returns(String) }
      def message
        'アクセス制限に達しました。'
      end
    end
  end
end
