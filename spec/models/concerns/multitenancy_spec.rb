# typed: false

require 'spec_helper'

describe Multitenancy do
  not_multitenant_models = [Tenant, Ruler].freeze
  Rails.application.eager_load!

  ActiveSupport::DescendantsTracker.descendants(ApplicationRecord).each do |model|
    should_multitenant_model = not_multitenant_models.exclude?(model)

    describe model.to_s do
      it 'should include Multitenancy' do
        expect(model.included_modules.include?(described_class)).to be should_multitenant_model
      end
    end
  end
end
