# typed: strict

module Deliveries
  module Birthday
    # SetupService prepares a daily birthday delivery for Blastengine bulk sending
    # Called ~15 mins before delivery_time by SetupWorker
    class SetupService
      extend T::Sig
      include Concerns::BlastengineSetup

      sig { params(birthday: DeliveryBirthday).void }
      def initialize(birthday:)
        @birthday = birthday
        @delivery = T.let(T.must(birthday.delivery), Delivery)
        @api = T.let(Blastengine::API.new, Blastengine::API)
        @today = T.let(Date.current, Date)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def execute
        # Skip if already setup for today
        if @birthday.last_setup_date == @today && @birthday.blastengine_job_id.present?
          return { success: true, message: 'Already setup for today' }
        end

        reset_daily_state if @birthday.last_setup_date != @today

        users = find_birthday_users
        if users.empty?
          @birthday.update!(last_setup_date: @today)
          return { success: true, message: 'No birthday users today' }
        end

        create_blastengine_delivery if @birthday.blastengine_delivery_id.blank?
        create_recipient_records(users)
        upload_csv

        @birthday.update!(status: 'preparing')

        { success: true, blastengine_delivery_id: @birthday.blastengine_delivery_id }
      rescue StandardError => e
        error_detail = build_error_detail(e)
        Rails.logger.error("[Birthday::SetupService] Failed: #{error_detail}")
        Rails.logger.error(e.backtrace&.first(10)&.join("\n"))
        { success: false, error: error_detail }
      end

      private

      sig { params(error: StandardError).returns(String) }
      def build_error_detail(error)
        return error.message unless error.respond_to?(:body)

        body = T.unsafe(error).body
        return error.message if body.blank?

        "#{error.message} | API: #{body}"
      end

      sig { void }
      def reset_daily_state
        @birthday.update!(
          blastengine_delivery_id: nil,
          blastengine_job_id: nil,
          setup_completed_at: nil,
          last_setup_date: @today,
        )
      end

      sig { returns(T.untyped) }
      def find_birthday_users
        return User.none if @delivery.user_tags.empty?

        target_date = @today - @birthday.offset_days.days

        already_sent_user_ids = DeliveryRecipient
          .where(delivery_id: @delivery.id)
          .where(delivery_date: @today.all_year)
          .pluck(:user_id)
          .to_set

        birthday_condition = Arel.sql(
          ActiveRecord::Base.sanitize_sql_array([
            'EXTRACT(MONTH FROM user_profiles.birth_date) = ? AND EXTRACT(DAY FROM user_profiles.birth_date) = ?',
            target_date.month,
            target_date.day,
          ]),
        )

        User
          .joins(:user_profile, :tag_assignments)
          .where(tag_assignments: { user_tag_id: @delivery.user_tag_ids })
          .where(birthday_condition)
          .where.not(id: already_sent_user_ids.to_a)
          .distinct
      end

      sig { void }
      def create_blastengine_delivery
        delivery_id = create_blastengine_bulk_delivery(delivery: @delivery, api: @api)
        @birthday.update!(blastengine_delivery_id: delivery_id)
        Rails.logger.info("[Birthday::SetupService] Created Blastengine delivery: #{delivery_id}")
      end

      sig { params(users: T.untyped).void }
      def create_recipient_records(users)
        now = Time.current
        users.find_in_batches(batch_size: 1000) do |batch|
          recipients = batch.map do |user|
            {
              tenant_id: @delivery.tenant_id,
              delivery_id: @delivery.id,
              user_id: user.id,
              delivery_date: @today,
              status: 'pending',
              scheduled_for: reservation_time,
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
                    .where(delivery_recipients: { delivery_id: @delivery.id, status: 'pending', delivery_date: @today })
                    .includes(:user_profile)

        job_id = upload_csv_to_blastengine(
          delivery_id: @birthday.blastengine_delivery_id.to_i,
          users: users,
          api: @api,
        )

        return unless job_id

        @birthday.update!(blastengine_job_id: job_id)
        Rails.logger.info("[Birthday::SetupService] CSV uploaded, job_id: #{job_id}")
      end

      sig { returns(ActiveSupport::TimeWithZone) }
      def reservation_time
        hour, minute = @birthday.delivery_time.split(':').map(&:to_i)
        Time.zone.local(@today.year, @today.month, @today.day, hour, minute)
      end
    end
  end
end
