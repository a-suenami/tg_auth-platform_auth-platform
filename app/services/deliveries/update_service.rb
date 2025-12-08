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

      success = T.let(false, T::Boolean)
      ActiveRecord::Base.transaction do
        delivery.user_tag_ids = new_tag_ids if tags_changed

        unless delivery.update(delivery_params)
          raise ActiveRecord::Rollback
        end

        child_changed = update_child
        delivery_changed = (delivery.saved_changes.keys - ['updated_at']).any?
        has_changes = delivery_changed || tags_changed || child_changed

        if has_changes
          delivery.update_column(:updated_by_id, admin.id)
          record_event(DeliveryEvent::Type::Updated.new)
        end

        success = true
      end

      success
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

    sig { returns(T::Boolean) }
    def check_tags_changed
      old_tag_ids = delivery.user_tag_ids.map(&:to_s).sort
      new_tag_ids_normalized = new_tag_ids.map(&:to_s).compact_blank.sort
      old_tag_ids != new_tag_ids_normalized
    end

    sig { returns(T::Boolean) }
    def update_child
      if delivery.schedule
        update_schedule
      elsif delivery.birthday
        update_birthday
      else
        false
      end
    end

    sig { returns(T::Boolean) }
    def update_schedule
      schedule = T.must(delivery.schedule)
      schedule.assign_attributes(scheduled_at: schedule_params[:scheduled_at])
      changed = schedule.changed?
      schedule.save! if changed
      changed
    end

    sig { returns(T::Boolean) }
    def update_birthday
      birthday = T.must(delivery.birthday)
      birthday.assign_attributes(
        offset_days: birthday_params[:offset_days] || 0,
        delivery_time: birthday_params[:delivery_time] || '09:00',
      )
      changed = birthday.changed?
      birthday.save! if changed
      changed
    end

    sig { params(event: DeliveryEvent::Type::Base).void }
    def record_event(event)
      DeliveryEvent.record!(delivery: delivery, event: event, admin: admin)
    end
  end
end
