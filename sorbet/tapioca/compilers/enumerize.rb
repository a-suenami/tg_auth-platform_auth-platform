# typed: true

# ==============================================================================
# sorbet - tapioca - compilers - enumerize
# ==============================================================================
require "tapioca/dsl"
require 'sorbet-runtime'
::Method.prepend(T::CompatibilityPatches::MethodExtensions)

module Tapioca
  module Compilers
    class Enumerize < Tapioca::Dsl::Compiler
      extend T::Sig

      ConstantType = type_member {{ fixed: T.class_of(::Enumerize) }}

      sig { override.returns(T::Enumerable[Module]) }
      def self.gather_constants
        all_classes.select { |c| c < ::Enumerize::Base }
      end

      sig { override.void }
      def decorate
        root.create_path(constant) do |model|
          # enumerize :kind, in: [:foo, :bar, :baz] が書かれているとする

          constant.enumerized_attributes.each do |enumerized_attribute|
            # まず record.kind が返す型として、実際は存在しない型を定義する
            # そこに対して foo?, bar?, baz? などのメソッドを定義する
            class_name = "::Enumerize::Value::#{constant}::#{enumerized_attribute.name.to_s.camelize}"
            model.create_class(class_name, superclass_name: '::Enumerize::Value') do |klass|
              enumerized_attribute.values.each do |value|
                # record.kind.foo? を定義する
                klass.create_method("#{value}?", return_type: 'T::Boolean')
              end

              klass.create_method('enum', return_type: enumerized_attribute.enum_class&.to_s)

              # record.kind == 'foo' のように == での比較では右辺を String しか取らない
              klass.create_method('==', parameters: [create_param('other', type: enumerized_attribute.enum_class&.to_s || 'String')], return_type: 'T::Boolean')
              klass.create_method('!=', parameters: [create_param('other', type: enumerized_attribute.enum_class&.to_s || 'String')], return_type: 'T::Boolean')
              klass.create_method('===', parameters: [create_param('other', type: enumerized_attribute.enum_class&.to_s || 'String')], return_type: 'T::Boolean')
            end

            model.create_method(enumerized_attribute.name, return_type: "T.nilable(#{class_name})")
          end
        end
      end
    end
  end
end
