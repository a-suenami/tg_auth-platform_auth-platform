# typed: false

require 'spec_helper'

RSpec.describe UserEvent do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant_id: tenant.id) }

  class UserEvent::Type::SampleEvent < UserEvent::Type::Base
    attribute :foo, :string
    attribute :bar, :integer

    validates :foo, presence: true
  end

  describe '.record!' do
    context 'with valid event' do
      let(:event) { UserEvent::Type::SampleEvent.new(foo: 'test', bar: 123) }

      it 'creates a user event' do
        expect { described_class.record!(user: user, event: event) }.to change(described_class, :count).by(1)
      end

      it 'records correct attributes' do
        record = described_class.record!(user: user, event: event)

        expect(record.tenant_id).to eq(tenant.id)
        expect(record.user_id).to eq(user.id)
        expect(record.event_type).to eq('sample_event')
        expect(record.payload).to eq({ 'foo' => 'test', 'bar' => 123 })
        expect(record.transaction_time).to be_present
      end

      it 'allows custom transaction_time' do
        custom_time = 1.day.ago
        record = described_class.record!(user: user, event: event, transaction_time: custom_time)

        expect(record.transaction_time).to be_within(1.second).of(custom_time)
      end
    end

    context 'with invalid event' do
      let(:event) { UserEvent::Type::SampleEvent.new(foo: nil, bar: 123) }

      it 'raises ActiveModel::ValidationError' do
        expect { described_class.record!(user: user, event: event) }.to raise_error(ActiveModel::ValidationError)
      end
    end
  end
end
