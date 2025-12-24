# typed: strict

module Deliveries
  class PublishService < BaseService
    extend T::Sig

    sig { returns(T::Boolean) }
    def execute
      return false unless valid_for_publish?

      child = delivery.schedule || delivery.birthday
      return false unless child

      ActiveRecord::Base.transaction do
        child.update!(
          status: delivery.schedule_type? ? 'scheduled' : 'ongoing',
          published_at: Time.current,
          published_by: admin,
        )
        record_event(DeliveryEvent::Type::Published.new)
      end

      true
    end

    private

    sig { returns(T::Boolean) }
    def valid_for_publish?
      if Tenant.current&.tenant_setting&.sender_email.blank?
        delivery.errors.add(:base, I18n.t('admin_area.deliveries.errors.sender_email_required'))
        return false
      end
      true
    end
  end
end
