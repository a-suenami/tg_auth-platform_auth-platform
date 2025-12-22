# typed: strict
# frozen_string_literal: true

# Registry for feature flags with descriptions and scopes
# Add new features here and run `rails db:seed_fu FILTER=023_feature_flags`
#
# Scopes:
#   :tenant - Shown in tenant-specific settings (can be enabled per-tenant)
#   :global - Shown only in global settings (not tenant-specific)
class FeatureFlagRegistry
  extend T::Sig

  FlagConfig = T.type_alias { { description: String, scope: Symbol } }

  FLAGS = T.let({
    delivery: { description: '配信機能を有効化', scope: :tenant },
    admin_new_ui: { description: '管理画面の新UIを有効化', scope: :tenant },
    ruler_new_ui: { description: 'Ruler管理画面の新UIを有効化', scope: :global },
    user_tag: { description: 'タグ機能を有効化', scope: :tenant },
    komoju_payment: { description: 'コンビニ決済を有効化', scope: :tenant },
  }.freeze, T::Hash[Symbol, FlagConfig],)

  class << self
    extend T::Sig

    sig { returns(T::Array[Symbol]) }
    def all_flags
      FLAGS.keys
    end

    # Flags that can be enabled per-tenant
    sig { returns(T::Array[Symbol]) }
    def tenant_flags
      FLAGS.select { |_, v| v[:scope] == :tenant }.keys
    end

    # Flags that are global-only
    sig { returns(T::Array[Symbol]) }
    def global_flags
      FLAGS.select { |_, v| v[:scope] == :global }.keys
    end

    sig { params(flag: Symbol).returns(T.nilable(String)) }
    def description(flag)
      FLAGS.dig(flag, :description)
    end

    sig { params(flag: Symbol).returns(T.nilable(Symbol)) }
    def scope(flag)
      FLAGS.dig(flag, :scope)
    end

    sig { params(flag: Symbol).returns(T::Boolean) }
    def valid?(flag)
      FLAGS.key?(flag)
    end

    sig { params(flag: Symbol).returns(T::Boolean) }
    def tenant_flag?(flag)
      FLAGS.dig(flag, :scope) == :tenant
    end

    sig { params(flag: Symbol).returns(T::Boolean) }
    def global_flag?(flag)
      FLAGS.dig(flag, :scope) == :global
    end

    # Register all flags in Flipper (called from seed)
    sig { void }
    def seed!
      FLAGS.each_key do |flag|
        Flipper.add(flag)
      end
    end
  end
end
