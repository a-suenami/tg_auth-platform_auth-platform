# typed: false
# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ButtonComponent, type: :component do
  describe '#render' do
    it 'renders the button with label' do
      render_inline(described_class.new(label: 'Click me'))

      expect(page).to have_button('Click me')
    end

    it 'applies default variant class' do
      render_inline(described_class.new(label: 'Button'))

      expect(page).to have_css('.btn.btn-primary.btn-md')
    end
  end

  describe 'variants' do
    %w[primary secondary danger].each do |variant|
      it "renders #{variant} variant" do
        render_inline(described_class.new(label: 'Button', variant: variant))

        expect(page).to have_css(".btn-#{variant}")
      end
    end

    it 'falls back to primary for invalid variant' do
      render_inline(described_class.new(label: 'Button', variant: 'invalid'))

      expect(page).to have_css('.btn-primary')
    end
  end

  describe 'sizes' do
    %w[sm md lg].each do |size|
      it "renders #{size} size" do
        render_inline(described_class.new(label: 'Button', size: size))

        expect(page).to have_css(".btn-#{size}")
      end
    end

    it 'falls back to md for invalid size' do
      render_inline(described_class.new(label: 'Button', size: 'invalid'))

      expect(page).to have_css('.btn-md')
    end
  end

  describe 'disabled state' do
    it 'renders disabled button' do
      render_inline(described_class.new(label: 'Disabled', disabled: true))

      expect(page).to have_css('.btn-disabled')
      expect(page).to have_button('Disabled', disabled: true)
    end
  end
end
