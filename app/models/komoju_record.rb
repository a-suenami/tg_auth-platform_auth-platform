# typed: strict
# frozen_string_literal: true

class KomojuRecord
  extend T::Sig

  sig { returns(String) }
  def self.table_name_prefix
    'komoju_record_'
  end

  class KomojuError < StandardError
    extend T::Sig

    sig { returns(T.nilable(Exception)) }
    attr_reader :raw_exception

    sig { params(exception: T.nilable(Exception)).void }
    def initialize(exception = nil)
      super
      @raw_exception = T.let(exception, T.nilable(Exception))
    end
  end

  class ConnectionError < KomojuError; end
  class APIConnectionError < KomojuError; end
  class APIError < KomojuError; end
  class RateLimitError < KomojuError; end
  class InvalidRequestError < KomojuError; end
  class UnauthorizedError < KomojuError; end
  class UnknownError < KomojuError; end

  sig { params(tenant: Tenant).returns(Client) }
  def self.client(tenant:)
    # 別テナントの API Key がセットされるのを防ぐために都度初期化する
    @client = T.let(Client.new(tenant: tenant), T.nilable(Client))
    T.must(@client)
  end

  class Client
    extend T::Sig

    sig { params(tenant: Tenant).void }
    def initialize(tenant:)
      komoju_account = tenant.tenant_komoju_account

      unless komoju_account&.enabled?
        raise Exceptions::Payment::Konbini::AccountNotConfigured
      end

      api_key = komoju_account.secret_key
      @komoju_client = T.let(Komoju.connect(api_key), Komoju::Client)
    end

    sig { returns(Payments) }
    def payments
      @payments ||= T.let(Payments.new(@komoju_client), T.nilable(Payments))
      @payments
    end

    sig { type_parameters(:T).params(block: T.proc.returns(T.type_parameter(:T))).returns(T.type_parameter(:T)) }
    def self.handle_exception(&block)
      block.call
    rescue Excon::Error::BadRequest, Excon::Error::UnprocessableEntity => e
      raise InvalidRequestError, e
    rescue Excon::Error::Unauthorized => e
      raise UnauthorizedError, e
    rescue Excon::Error::TooManyRequests => e
      raise RateLimitError, e
    rescue Excon::Error::GatewayTimeout => e
      raise APIConnectionError, e
    rescue Excon::Error::InternalServerError, Excon::Error::BadGateway, Excon::Error::ServiceUnavailable => e
      raise APIError, e
    rescue Excon::Error => e
      raise ConnectionError, e
    rescue StandardError => e
      raise UnknownError, e
    end

    # Nested Payments class
    class Payments
      extend T::Sig

      sig { params(komoju_client: Komoju::Client).void }
      def initialize(komoju_client)
        @komoju_client_payments = T.let(komoju_client.payments, Komoju::Payments)
      end

      # Konbini store enum
      class KonbiniStore < T::Enum
        enums do
          SevenEleven = new('seven-eleven')
          Lawson = new('lawson')
          FamilyMart = new('family-mart')
        end
      end

      # Konbini params struct
      class KonbiniParams < T::Struct
        const :type, String, default: 'konbini'
        prop :store, String
        prop :email, String
        prop :phone, T.nilable(String)
        prop :expiry_days, T.nilable(Integer)
        prop :given_name, T.nilable(String)
        prop :family_name, T.nilable(String)
      end

      # Create params struct
      class CreateParams < T::Struct
        prop :amount, Integer
        prop :tax, Integer, default: 0
        prop :currency, String
        prop :external_order_num, String
        prop :customer, T.nilable(String)
        prop :payment_details, T.nilable(KonbiniParams)
        prop :return_url, T.nilable(String)
        prop :capture, T::Boolean, default: true
      end

      sig { params(params: CreateParams).returns(T::Hash[String, T.untyped]) }
      def create(params)
        Client.handle_exception do
          @komoju_client_payments.create(params.serialize)
        end
      end

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def show(id)
        Client.handle_exception do
          @komoju_client_payments.show(id)
        end
      end

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def capture(id)
        Client.handle_exception do
          @komoju_client_payments.capture(id)
        end
      end

      sig { params(id: String).returns(T::Hash[String, T.untyped]) }
      def cancel(id)
        Client.handle_exception do
          @komoju_client_payments.cancel(id)
        end
      end

      sig { params(external_order_num: String).returns(T::Hash[String, T.untyped]) }
      def list(external_order_num:)
        Client.handle_exception do
          @komoju_client_payments.list(external_order_num: external_order_num)
        end
      end
    end
  end
end
