# typed: strict

module Exceptions
  module Shopify
    class BaseError < Exceptions::BaseError; end

    class TokenInvalidError < BaseError
      sig { returns(Symbol) }
      def code
        :token_invalid_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.shopify.token_invalid_error'
      end
    end

    class WebhookEventInvaildError < BaseError
      sig { returns(Symbol) }
      def code
        :webhook_event_invalid_error
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.shopify.webhook_event_invalid_error'
      end
    end
  end
end
