# typed: strict
# frozen_string_literal: true

class ButtonComponent < ViewComponent::Base
  extend T::Sig

  VARIANTS = T.let(%w[primary secondary danger].freeze, T::Array[String])
  SIZES = T.let(%w[sm md lg].freeze, T::Array[String])

  sig { returns(String) }
  attr_reader :label

  sig { returns(String) }
  attr_reader :variant

  sig { returns(String) }
  attr_reader :size

  sig { returns(T::Boolean) }
  attr_reader :disabled

  sig do
    params(
      label: String,
      variant: String,
      size: String,
      disabled: T::Boolean
    ).void
  end
  def initialize(label:, variant: 'primary', size: 'md', disabled: false)
    super()
    @label = label
    @variant = VARIANTS.include?(variant) ? variant : 'primary'
    @size = SIZES.include?(size) ? size : 'md'
    @disabled = disabled
  end

  sig { returns(String) }
  def css_classes
    classes = ['btn']
    classes << "btn-#{variant}"
    classes << "btn-#{size}"
    classes << 'btn-disabled' if disabled
    classes.join(' ')
  end
end
