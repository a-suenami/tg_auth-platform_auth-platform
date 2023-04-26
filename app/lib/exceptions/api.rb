# typed: false

module Exceptions
  module API
    class BaseError < Exceptions::BaseError; end

    class ServerError < BaseError
      attr_accessor :status, :body

      def initialize(status: nil, body: nil)
        @status = status
        @body = body
      end

      def code
        :server_error
      end

      def message
        '外部APIがエラーしました'
      end
    end

    class InvalidRequestError < BaseError
      def code
        :invalid_request_error
      end

      def message
        '不正なリクエストです'
      end
    end

    class RequestLimitError < BaseError
      def code
        :request_limit_error
      end

      def message
        'アクセス制限に達しました。'
      end
    end
  end
end
