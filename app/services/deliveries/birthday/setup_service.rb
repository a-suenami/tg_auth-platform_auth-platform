# typed: strict

module Deliveries
  module Birthday
    # SetupService prepares a daily birthday delivery for Blastengine bulk sending
    # Called ~15 mins before delivery_time by SetupWorker
    #
    # Steps:
    # 1. Find users with birthday on target date (today +/- offset_days)
    # 2. Create Blastengine bulk delivery (get delivery_id)
    # 3. Create DeliveryRecipient records
    # 4. Generate CSV, upload to Blastengine (get job_id)
    # 5. Set status to 'preparing' and exit
    #
    # ConfirmImportWorker will:
    # - Check import status
    # - Commit with reservation when ready
    # - Update status to 'delivering'
    #
    # Daily reset: Each day starts fresh (blastengine IDs cleared)
    class SetupService
      extend T::Sig

      sig { params(birthday: DeliveryBirthday).void }
      def initialize(birthday:)
        @birthday = birthday
        @delivery = T.let(T.must(birthday.delivery), Delivery)
        @api = T.let(Blastengine::API.new, Blastengine::API)
        @today = T.let(Date.current, Date)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def execute
        # Skip if already setup for today (has job_id means CSV uploaded)
        if @birthday.last_setup_date == @today && @birthday.blastengine_job_id.present?
          return { success: true, message: 'Already setup for today' }
        end

        # Reset daily state if new day
        reset_daily_state if @birthday.last_setup_date != @today

        # Find birthday users for today
        users = find_birthday_users
        if users.empty?
          @birthday.update!(last_setup_date: @today)
          return { success: true, message: 'No birthday users today' }
        end

        # Step 1: Create Blastengine bulk delivery (if not already created)
        create_blastengine_delivery if @birthday.blastengine_delivery_id.blank?

        # Step 2: Create recipient records
        create_recipient_records(users)

        # Step 3: Generate and upload CSV
        upload_csv

        # Step 4: Set status to preparing (ConfirmImportWorker will handle the rest)
        @birthday.update!(status: 'preparing')

        { success: true, blastengine_delivery_id: @birthday.blastengine_delivery_id }
      rescue StandardError => e
        Rails.logger.error("[Birthday::SetupService] Failed: #{e.message}")
        Rails.logger.error(e.backtrace&.first(10)&.join("\n"))
        { success: false, error: e.message }
      end

      private

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

        # offset_days: -7 means send 7 days BEFORE birthday (find birthday = today + 7)
        # offset_days: 0 means send ON birthday (find birthday = today)
        # offset_days: 3 means send 3 days AFTER birthday (find birthday = today - 3)
        target_date = @today - @birthday.offset_days.days

        # Get already sent user IDs this year (avoid duplicates for same delivery)
        # Note: Different deliveries (campaigns) can still send to same user
        already_sent_user_ids = DeliveryRecipient
          .where(delivery_id: @delivery.id)
          .where(delivery_date: @today.all_year)
          .pluck(:user_id)
          .to_set

        # Build query for birthday match (month + day)
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
        template = T.must(@delivery.template)
        mail_version = template.template_mail_versions.published.order(created_at: :desc).first
        raise 'No published mail version' unless mail_version

        from_email = Tenant.current&.tenant_setting&.sender_email || 'idp@id-platform.net'
        from_name = Tenant.current&.name || 'ID Platform'

        # Render template with insert code placeholders for Blastengine
        subject = render_with_insert_codes(mail_version.title)
        body = render_with_insert_codes(mail_version.body)

        result = @api.bulk_begin(
          subject: subject,
          text_part: ActionView::Base.full_sanitizer.sanitize(body, tags: []),
          html_part: body,
          from_email: from_email,
          from_name: from_name,
        )

        @birthday.update!(blastengine_delivery_id: result['delivery_id'])
        Rails.logger.info("[Birthday::SetupService] Created Blastengine delivery: #{result['delivery_id']}")
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

        return if users.empty?

        csv_content = CsvGenerator.new(users: users).generate

        result = @api.bulk_import_csv(
          delivery_id: @birthday.blastengine_delivery_id.to_i,
          csv_content: csv_content,
        )

        @birthday.update!(blastengine_job_id: result['job_id'])
        Rails.logger.info("[Birthday::SetupService] CSV uploaded, job_id: #{result['job_id']}")
      end

      sig { returns(ActiveSupport::TimeWithZone) }
      def reservation_time
        # Combine today's date with delivery_time (HH:MM)
        hour, minute = @birthday.delivery_time.split(':').map(&:to_i)
        Time.zone.local(@today.year, @today.month, @today.day, hour, minute)
      end

      # Convert Liquid variables to Blastengine insert codes
      # Blastengine requires alphanumeric only keys (no underscores inside)
      sig { params(template_text: String).returns(String) }
      def render_with_insert_codes(template_text)
        template_text
          .gsub('{{ first_name }}', '__firstname__')
          .gsub('{{ last_name }}', '__lastname__')
          .gsub('{{ full_name }}', '__fullname__')
          .gsub('{{first_name}}', '__firstname__')
          .gsub('{{last_name}}', '__lastname__')
          .gsub('{{full_name}}', '__fullname__')
      end
    end
  end
end
