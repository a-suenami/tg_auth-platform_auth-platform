# typed: strict

module Deliveries
  module FixedTime
    # SetupService prepares a scheduled delivery for Blastengine bulk sending
    # Called ~15 mins before scheduled_at by SetupWorker
    class SetupService
      extend T::Sig
      include Concerns::BlastengineSetup

      sig { params(schedule: DeliverySchedule).void }
      def initialize(schedule:)
        @schedule = schedule
        @delivery = T.let(T.must(schedule.delivery), Delivery)
        @api = T.let(Blastengine::API.new, Blastengine::API)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def execute
        return { success: true, message: 'Already setup' } if @schedule.blastengine_job_id.present?

        create_blastengine_delivery if @schedule.blastengine_delivery_id.blank?
        create_recipient_records
        upload_csv

        @schedule.update!(status: 'preparing')

        { success: true, blastengine_delivery_id: @schedule.blastengine_delivery_id }
      rescue StandardError => e
        Rails.logger.error("[FixedTime::SetupService] Failed: #{e.message}")
        Rails.logger.error(e.backtrace&.first(10)&.join("\n"))
        { success: false, error: e.message }
      end

      private

      sig { void }
      def create_blastengine_delivery
        delivery_id = create_blastengine_bulk_delivery(delivery: @delivery, api: @api)
        @schedule.update!(blastengine_delivery_id: delivery_id)
        Rails.logger.info("[FixedTime::SetupService] Created Blastengine delivery: #{delivery_id}")
      end

      sig { void }
      def create_recipient_records
        now = Time.current
        delivery_date = T.must(@schedule.scheduled_at).to_date

        target_users.find_in_batches(batch_size: 1000) do |users|
          recipients = users.map do |user|
            {
              tenant_id: @delivery.tenant_id,
              delivery_id: @delivery.id,
              user_id: user.id,
              delivery_date: delivery_date,
              status: 'pending',
              scheduled_for: @schedule.scheduled_at,
              created_at: now,
              updated_at: now,
            }
          end
          DeliveryRecipient.insert_all(recipients, unique_by: [:delivery_id, :user_id, :delivery_date])
        end
      end

      sig { void }
      def upload_csv
        users = User.joins(:delivery_recipients)
                    .where(delivery_recipients: { delivery_id: @delivery.id })
                    .includes(:user_profile)

        job_id = upload_csv_to_blastengine(
          delivery_id: @schedule.blastengine_delivery_id.to_i,
          users: users,
          api: @api,
        )

        return unless job_id

        @schedule.update!(blastengine_job_id: job_id)
        Rails.logger.info("[FixedTime::SetupService] CSV uploaded, job_id: #{job_id}")
      end

      sig { returns(T.untyped) }
      def target_users
        return User.none if @delivery.user_tags.empty?

        User.joins(:tag_assignments)
            .where(tag_assignments: { user_tag_id: @delivery.user_tag_ids })
            .distinct
      end
    end
  end
end
