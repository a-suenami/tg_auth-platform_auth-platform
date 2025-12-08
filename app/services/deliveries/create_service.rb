# typed: strict

module Deliveries
  class CreateService < BaseService
    extend T::Sig

    sig do
      params(
        delivery: Delivery,
        admin: Admin,
        delivery_type: String,
        schedule_params: T::Hash[Symbol, T.untyped],
        birthday_params: T::Hash[Symbol, T.untyped],
      ).void
    end
    def initialize(delivery:, admin:, delivery_type:, schedule_params: {}, birthday_params: {})
      super(delivery: delivery, admin: admin)
      @delivery_type = delivery_type
      @schedule_params = schedule_params
      @birthday_params = birthday_params
    end

    sig { returns(T::Boolean) }
    def execute
      delivery.created_by = admin

      success = T.let(false, T::Boolean)
      ActiveRecord::Base.transaction do
        unless delivery.save
          raise ActiveRecord::Rollback
        end

        build_child
        record_event(DeliveryEvent::Type::Created.new)
        success = true
      end

      success
    end

    private

    sig { returns(String) }
    attr_reader :delivery_type

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :schedule_params

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :birthday_params

    sig { void }
    def build_child
      if delivery_type == 'birthday'
        delivery.create_birthday!(
          tenant: Tenant.current,
          status: 'draft',
          offset_days: birthday_params[:offset_days] || 0,
          delivery_time: birthday_params[:delivery_time] || '09:00',
        )
      else
        delivery.create_schedule!(
          tenant: Tenant.current,
          status: 'draft',
          scheduled_at: schedule_params[:scheduled_at],
        )
      end
    end

    sig { params(event: DeliveryEvent::Type::Base).void }
    def record_event(event)
      DeliveryEvent.record!(delivery: delivery, event: event, admin: admin)
    end
  end
end
