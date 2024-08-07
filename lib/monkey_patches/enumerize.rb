# typed: strict

# ==============================================================================
# lib/monkey_patches/enumerize.rb
# ==============================================================================
module ::Enumerize
  module AttributeMonkeyPatch
    extend T::Sig
    extend T::Helpers

    requires_ancestor { ::Enumerize::Attribute }

    sig { returns(T.nilable(T.class_of(T::Enum))) }
    attr_reader :enum_class

    sig { params(klass: T.untyped, name: T.untyped, options: T::Hash[T.untyped, T.untyped]).void }
    def initialize(klass, name, options = {})
      @enum_class = T.let(options[:enum_class], T.nilable(T.class_of(T::Enum)))

      if @enum_class
        options[:in] = @enum_class.values.map(&:serialize)
      end

      super
    end
  end

  module ValueMonkeyPatch
    extend T::Sig
    extend T::Helpers

    requires_ancestor { ::Enumerize::Value }

    sig { returns(T::Enum) }
    def enum
      self.instance_variable_get('@attr').enum_class.deserialize(self.value)
    end

    sig { params(other: T.any(T.nilable(String), T.nilable(T::Enum))).returns(T::Boolean) }
    def ==(other)
      if other.is_a?(T::Enum)
        super(other.serialize)
      else
        super(other)
      end
    end

    sig { params(other: T.nilable(T::Enum)).returns(T::Boolean) }
    def ===(other)
      if other.is_a?(T::Enum)
        super(other.serialize)
      else
        raise 'do not compare with other than T::Enum'
      end
    end

    sig { params(other: T.any(T.nilable(String), T.nilable(T::Enum))).returns(T::Boolean) }
    def !=(other)
      if other.is_a?(T::Enum)
        super(other.serialize)
      else
        super(other)
      end
    end
  end

  ::Enumerize::Attribute.prepend(::Enumerize::AttributeMonkeyPatch)
  ::Enumerize::Value.prepend(::Enumerize::ValueMonkeyPatch)
end
