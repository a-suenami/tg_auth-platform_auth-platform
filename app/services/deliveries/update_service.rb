# typed: strict

module Deliveries
  class UpdateService < BaseService
    extend T::Sig

    sig do
      params(
        delivery: Delivery,
        admin: Admin,
        delivery_params: T::Hash[Symbol, T.untyped],
        new_tag_ids: T::Array[String],
        schedule_params: T::Hash[Symbol, T.untyped],
        birthday_params: T::Hash[Symbol, T.untyped],
      ).void
    end
    def initialize(delivery:, admin:, delivery_params:, new_tag_ids:, schedule_params: {}, birthday_params: {})
      super(delivery: delivery, admin: admin)
      @delivery_params = delivery_params
      @new_tag_ids = new_tag_ids
      @schedule_params = schedule_params
      @birthday_params = birthday_params
    end

    sig { returns(T::Boolean) }
    def execute
      old_ids = delivery.user_tag_ids.map(&:to_s).sort
      new_ids = new_tag_ids.map(&:to_s).compact_blank.sort
      tags_changed = old_ids != new_ids

      # Validate delivery with new params
      delivery.assign_attributes(delivery_params)
      return false unless delivery.valid?

      # Validate child record
      child = delivery.schedule || delivery.birthday
      if child
        assign_child_attributes(child)
        unless child.valid?
          child.errors.each { |error| delivery.errors.add(:base, error.full_message) }
          return false
        end
      end

      ActiveRecord::Base.transaction do
        delivery.user_tag_ids = new_tag_ids if tags_changed
        delivery.save!

        child_changed = child&.changed? || false
        child&.save!

        delivery_changed = (delivery.saved_changes.keys - ['updated_at']).any?
        has_changes = delivery_changed || tags_changed || child_changed

        if has_changes
          delivery.update_column(:updated_by_id, admin.id)
          record_event(DeliveryEvent::Type::Updated.new)
        end
      end

      true
    end

    private

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :delivery_params

    sig { returns(T::Array[String]) }
    attr_reader :new_tag_ids

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :schedule_params

    sig { returns(T::Hash[Symbol, T.untyped]) }
    attr_reader :birthday_params

    sig { params(child: T.any(DeliverySchedule, DeliveryBirthday)).void }
    def assign_child_attributes(child)
      case child
      when DeliverySchedule
        child.assign_attributes(scheduled_at: schedule_params[:scheduled_at])
      when DeliveryBirthday
        child.assign_attributes(
          offset_days: birthday_params[:offset_days] || 0,
          delivery_time: birthday_params[:delivery_time] || '09:00',
        )
      end
    end
  end
end
