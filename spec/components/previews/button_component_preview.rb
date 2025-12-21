# typed: false
# frozen_string_literal: true

# @label Button
class ButtonComponentPreview < ViewComponent::Preview
  # Primary button (default)
  # ----------------
  # The default button style for primary actions
  #
  # @param label text "Button label"
  def default(label: 'Click me')
    render(ButtonComponent.new(label: label))
  end

  # Button variants
  # ----------------
  # Different visual styles for different use cases
  def variants
    render_with_template(
      template: 'button_component_preview/variants'
    )
  end

  # Button sizes
  # ----------------
  # Available size options: sm, md, lg
  def sizes
    render_with_template(
      template: 'button_component_preview/sizes'
    )
  end

  # Disabled state
  # ----------------
  # Button in disabled state
  def disabled
    render(ButtonComponent.new(label: 'Disabled Button', disabled: true))
  end

  # Interactive playground
  # ----------------
  # Try different combinations of options
  #
  # @param label text "Button text"
  # @param variant select { choices: [primary, secondary, danger] }
  # @param size select { choices: [sm, md, lg] }
  # @param disabled toggle
  def playground(label: 'Button', variant: 'primary', size: 'md', disabled: false)
    render(ButtonComponent.new(
             label: label,
             variant: variant,
             size: size,
             disabled: disabled
           ))
  end
end
