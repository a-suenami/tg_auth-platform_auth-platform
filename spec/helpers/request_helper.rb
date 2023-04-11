# typed: false

# ==============================================================================
# spec - request helpers
# ==============================================================================
module RequestHelpers
  def body_hash
    ActiveSupport::HashWithIndifferentAccess.new(JSON.parse(response.body)) if response.body.present?
  end

  def body_data
    data = body_hash[:data]

    def data.attributes_map
      self.map do |datum|
        yield ActiveSupport::InheritableOptions.new(datum[:attributes])
      end
    end

    data
  end

  def body_included
    body_hash[:included]
  end

  class ObjectMock
    def initialize(record, included_records)
      @record = record
      @included_records = included_records
      @relationships = []

      define_singleton_method :id do
        @record[:id]
      end

      # attributes, relationships に type が使われない前提
      define_singleton_method :type do
        @record[:type]
      end

      @record[:attributes]&.each do |attribute, value|
        define_singleton_method attribute do
          value
        end
      end

      @record[:relationships]&.each do |relationship, data|
        data = data[:data]

        @relationships << relationship

        if data.is_a? Array
          children = data.map do |d|
            child = @included_records.find { _1[:type] == d[:type] && _1[:id] == d[:id] }
            ObjectMock.new(child, @included_records)
          end

          define_singleton_method relationship do
            children
          end
        else
          child = if data.present?
            child = @included_records.find { _1[:type] == data[:type] && _1[:id] == data[:id] }
            ObjectMock.new(child, @included_records)
          end

          define_singleton_method relationship do
            child
          end
        end
      end
    end

    def inspect
      {
        attributes: @record[:attributes],
        relationships: @relationships,
      }
    end
  end

  def deserialize
    if body_data.is_a? Array
      body_data.map { ObjectMock.new(_1, body_included) }
    else
      ObjectMock.new(body_data, body_included)
    end
  end

  def deserialized
    @deserialized ||= deserialize
  end

  def self.included(base)
    base.instance_eval do
      let(:current_tenant) { create(:tenant, id: :sample, name: 'サンプル', domain: 'sample.localhost.com') }
      let(:current_user) { create(:user, tenant_id: current_tenant.id) }

      before do
        RequestStore.store[:current_tenant_domain] = "#{current_tenant.id}.localhost.com" || '-'
        host! "#{current_tenant.id}.localhost.com"
      end
    end
  end
end
