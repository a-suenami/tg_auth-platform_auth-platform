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
        time = Time.zone.now.round(6)
        record = described_class.record!(user: user, event: event, transaction_time: time)

        expect(record.tenant_id).to eq(tenant.id)
        expect(record.user_id).to eq(user.id)
        expect(record.event_type).to eq('sample_event')
        expect(record.payload).to eq({ 'foo' => 'test', 'bar' => 123 })
        expect(record.transaction_time).to eq(time)
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
