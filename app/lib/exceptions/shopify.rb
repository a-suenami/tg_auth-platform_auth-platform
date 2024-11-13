# typed: strict

module Exceptions
  module Shopify
    class BaseError < Exceptions::BaseError; end

    class AdminApiError < BaseError
      sig { returns(T.nilable(String)) }
      attr_accessor :status, :error_message

      sig { params(status: T.nilable(Integer), error_message: T.nilable(String)).void }
      def initialize(status: nil, error_message: nil)
        @status = T.let(status, T.untyped)
        @error_message = T.let(error_message, T.nilable(String))
      end

      sig { returns(Symbol) }
      def code
        :admin_api_error
      end

      sig { returns(String) }
      def message
        @error_message || I18n.t('exceptions.shopify.admin_api_error')
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

    class TenantIsNotFound < BaseError
      sig { returns(Symbol) }
      def code
        :tenant_is_not_found
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.shopify.tenant_is_not_found'
      end
    end

    class ShopifyRecordMultipassSettingNotExist < BaseError
      sig { returns(Symbol) }
      def code
        :shopify_record_multipass_setting_not_exist
      end

      sig { returns(String) }
      def message
        I18n.t 'exceptions.shopify.shopify_record_multipass_setting_not_exist'
      end
    end
  end
end
