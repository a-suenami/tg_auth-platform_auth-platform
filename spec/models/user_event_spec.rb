# typed: false

require 'spec_helper'

RSpec.describe UserEvent do
  let(:tenant) { create(:tenant) }
  let(:user) { create(:user, tenant_id: tenant.id) }

  # テスト用サンプルイベント
  class UserEvent::Type::SampleEvent < UserEvent::Type::Base
    attribute :foo, :string
    attribute :bar, :integer

    validates :foo, presence: true
  end

  describe '.record!' do
    context 'with valid event' do
      let(:event) { UserEvent::Type::SampleEvent.new(foo: 'test', bar: 123) }

      it 'creates a user event' do
        expect { described_class.record!(user: user, event: event) }
          .to change(described_class, :count).by(1)
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
        expect { described_class.record!(user: user, event: event) }
          .to raise_error(ActiveModel::ValidationError)
      end
    end

  end

  describe 'Type classes' do
    describe UserEvent::Type::Created do
      it 'returns correct event_type_name' do
        event = described_class.new
        expect(event.event_type_name).to eq('created')
      end

      it 'returns empty payload' do
        event = described_class.new
        expect(event.to_payload).to eq({})
      end
    end

    describe UserEvent::Type::ManuallyTagged do
      it 'returns correct event_type_name' do
        event = described_class.new(tag_id: 'tag-1', tagged_by: 'admin-1')
        expect(event.event_type_name).to eq('manually_tagged')
      end

      it 'returns payload with tag_id and tagged_by' do
        event = described_class.new(tag_id: 'tag-1', tagged_by: 'admin-1')
        expect(event.to_payload).to eq({ 'tag_id' => 'tag-1', 'tagged_by' => 'admin-1' })
      end

      it 'is invalid without tag_id' do
        event = described_class.new(tag_id: nil, tagged_by: 'admin-1')
        expect(event).not_to be_valid
      end

      it 'is invalid without tagged_by' do
        event = described_class.new(tag_id: 'tag-1', tagged_by: nil)
        expect(event).not_to be_valid
      end
    end

    describe UserEvent::Type::AutoTagged do
      it 'returns correct event_type_name' do
        event = described_class.new(tag_id: 'tag-1', auto_tagging_rule_id: 'rule-1')
        expect(event.event_type_name).to eq('auto_tagged')
      end

      it 'returns payload with tag_id and auto_tagging_rule_id' do
        event = described_class.new(tag_id: 'tag-1', auto_tagging_rule_id: 'rule-1')
        expect(event.to_payload).to eq({ 'tag_id' => 'tag-1', 'auto_tagging_rule_id' => 'rule-1' })
      end

      it 'is invalid without tag_id' do
        event = described_class.new(tag_id: nil, auto_tagging_rule_id: 'rule-1')
        expect(event).not_to be_valid
      end

      it 'is invalid without auto_tagging_rule_id' do
        event = described_class.new(tag_id: 'tag-1', auto_tagging_rule_id: nil)
        expect(event).not_to be_valid
      end
    end
  end
end
