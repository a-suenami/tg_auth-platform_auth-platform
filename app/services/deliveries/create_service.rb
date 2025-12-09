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

      # Validate delivery first
      return false unless delivery.valid?

      # Validate child record
      child = build_child_record
      unless child.valid?
        child.errors.each { |error| delivery.errors.add(:base, error.full_message) }
        return false
      end

      ActiveRecord::Base.transaction do
        delivery.save!
        child.save!
        record_event(DeliveryEvent::Type::Created.new)
      end

      true
    end

    private

    sig { returns(String) }
    attr_reader :delivery_type

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :schedule_params

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :birthday_params

    sig { returns(T.any(DeliverySchedule, DeliveryBirthday)) }
    def build_child_record
      if delivery_type == 'birthday'
        delivery.build_birthday(
          tenant: Tenant.current,
          status: 'draft',
          offset_days: birthday_params[:offset_days] || 0,
          delivery_time: birthday_params[:delivery_time] || '09:00',
        )
      else
        delivery.build_schedule(
          tenant: Tenant.current,
          status: 'draft',
          scheduled_at: schedule_params[:scheduled_at],
        )
      end
    end
  end
end
