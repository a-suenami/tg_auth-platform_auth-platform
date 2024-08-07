# typed: strict

# ==============================================================================
# app/models/stripe_record.rb
# ==============================================================================
class StripeRecord
  extend T::Sig

  class Request3DS < T::Enum
    enums do
      None      = new('none')
      Any       = new('any')
      Automatic = new('automatic')
      Challenge = new('challenge')
    end
  end

  sig { returns(String) }
  def self.table_name_prefix
    'stripe_record_'
  end


  sig { params(stripe_account: T.nilable(String), stripe_version: T.nilable(String)).returns(T::Hash[Symbol, T.untyped]) }
  def self.opts(stripe_account: nil, stripe_version: nil)
    secret_key = T.must(Tenant.current!.tenant_stripe_account).api_key.secret_key
    _opts = {
      api_key: secret_key,
      stripe_version: '2024-04-10', # default
    }

    _opts[:stripe_account] = stripe_account if stripe_account.present?
    _opts[:stripe_version] = stripe_version if stripe_version.present? # 指定があれば default を上書きする

    _opts
  end

  module Client
    extend T::Sig
    extend T::Generic

    module ClassMethods
      extend T::Sig
      extend T::Generic

      StripeClass = type_member { { upper: Stripe::APIResource } }

      abstract!

      sig { abstract.returns(T::Class[StripeClass]) }
      def stripe_class; end

      sig {
        type_parameters(:Response)
          .params(
            block: T.proc.returns(StripeClass),
          )
          .returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def handle_exception(&block)
        Mangrove::Result.ok(block.call)
      rescue Stripe::StripeError => e
        Mangrove::Result.err(e)
      end

      sig { params(api_key: StripeRecord::APIKey, stripe_account: T.nilable(String), stripe_version: T.nilable(String)).returns(T::Hash[Symbol, T.untyped]) }
      def opts(api_key:, stripe_account: nil, stripe_version: nil)
        secret_key = api_key.secret_key
        _opts = {
          api_key: secret_key,
          stripe_version: '2024-04-10', # default
        }

        _opts[:stripe_account] = stripe_account if stripe_account.present?
        _opts[:stripe_version] = stripe_version if stripe_version.present? # 指定があれば default を上書きする

        _opts
      end

      sig {
        params(
          id: String, opts: T::Hash[Symbol, T.untyped], stripe_account_id: T.nilable(String), api_key: StripeRecord::APIKey, expand: T::Array[String],
        )
        .returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def retrieve(id, opts = {}, stripe_account_id:, api_key:, expand: [])
        self.handle_exception do
          T.unsafe(self.stripe_class).retrieve({ id:, expand: }, self.opts(api_key:, stripe_account: stripe_account_id).merge(opts))
        end
      end

      sig {
        params(
          params: T::Hash[T.untyped, T.untyped], opts: T::Hash[Symbol, T.untyped], stripe_account_id: T.nilable(String), api_key: StripeRecord::APIKey,
        )
        .returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def create(params = {}, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).create(params, self.opts(api_key:, stripe_account: stripe_account_id).merge(opts))
        end
      end
    end

    mixes_in_class_methods(ClassMethods)

    module Customer
      extend T::Sig
      extend T::Generic
      include Client

      StripeClass = type_template { { fixed: Stripe::Customer } }

      sig { override.returns(T::Class[StripeClass]) }
      def self.stripe_class = Stripe::Customer

      def self.update(customer_id, params = nil, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).update(customer_id, params, self.opts(api_key:, stripe_account: stripe_account_id).merge(opts))
        end
      end
    end

    module SetupIntent
      extend T::Sig
      extend T::Generic
      include Client

      StripeClass = type_template { { fixed: Stripe::SetupIntent } }

      sig { override.returns(T::Class[StripeClass]) }
      def self.stripe_class = Stripe::SetupIntent
    end

    module PaymentMethod
      extend T::Sig
      extend T::Generic
      include Client

      StripeClass = type_template { { fixed: Stripe::PaymentMethod } }

      sig { override.returns(T::Class[StripeClass]) }
      def self.stripe_class = Stripe::PaymentMethod

      sig {
        params(
          payment_method: String, params: T.nilable(T::Hash[T.untyped, T.untyped]), opts: T::Hash[Symbol, T.untyped], stripe_account_id: T.nilable(String), api_key: StripeRecord::APIKey,
        )
        .returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def self.attach(payment_method, params = nil, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).attach(payment_method, params, self.opts(api_key:, stripe_account: stripe_account_id).merge(opts))
        end
      end

      sig {
        params(
          payment_method: String, params: T.nilable(T::Hash[T.untyped, T.untyped]), opts: T::Hash[Symbol, T.untyped], stripe_account_id: T.nilable(String), api_key: StripeRecord::APIKey,
        )
        .returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def self.detach(payment_method, params = nil, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).detach(payment_method, params, self.opts(api_key:, stripe_account: stripe_account_id).merge(opts))
        end
      end
    end

    module PaymentIntent
      extend T::Sig
      extend T::Generic
      include Client

      StripeClass = type_template { { fixed: Stripe::PaymentIntent } }

      sig { override.returns(T::Class[StripeClass]) }
      def self.stripe_class = Stripe::PaymentIntent

      sig {
        params(
          id: String,
          opts: T::Hash[Symbol, T.untyped],
          stripe_account_id: T.nilable(String),
          api_key: StripeRecord::APIKey,
        ).returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def self.capture(id, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).capture(id, opts, self.opts(api_key:, stripe_account: stripe_account_id))
        end
      end

      sig {
        params(
          id: String,
          opts: T::Hash[Symbol, T.untyped],
          stripe_account_id: T.nilable(String),
          api_key: StripeRecord::APIKey,
        ).returns(Mangrove::Result[StripeClass, Stripe::StripeError])
      }
      def self.cancel(id, opts = {}, stripe_account_id:, api_key:)
        self.handle_exception do
          T.unsafe(self.stripe_class).cancel(id, opts, self.opts(api_key:, stripe_account: stripe_account_id))
        end
      end
    end

    module Refund
      extend T::Sig
      extend T::Generic
      include Client

      StripeClass = type_template { { fixed: Stripe::Refund } }

      sig { override.returns(T::Class[StripeClass]) }
      def self.stripe_class = Stripe::Refund
    end
  end
end
