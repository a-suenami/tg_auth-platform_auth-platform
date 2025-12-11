# typed: strict

module Deliveries
  module FixedTime
    # SetupService prepares a scheduled delivery for Blastengine bulk sending
    # Called ~15 mins before scheduled_at by SetupWorker
    #
    # Steps:
    # 1. Create Blastengine bulk delivery (get delivery_id)
    # 2. Fix user list (create DeliveryRecipient records)
    # 3. Generate CSV, upload to Blastengine (get job_id)
    # 4. Set status to 'preparing' and exit
    #
    # ConfirmImportWorker will:
    # - Check import status
    # - Commit with reservation when ready
    # - Update status to 'delivering'
    #
    # Idempotent: Safe to retry if fails midway
    class SetupService
      extend T::Sig

      sig { params(schedule: DeliverySchedule).void }
      def initialize(schedule:)
        @schedule = schedule
        @delivery = T.let(T.must(schedule.delivery), Delivery)
        @api = T.let(Blastengine::API.new, Blastengine::API)
      end

      sig { returns(T::Hash[Symbol, T.untyped]) }
      def execute
        # Skip if already setup (has job_id means CSV uploaded)
        if @schedule.blastengine_job_id.present?
          return { success: true, message: 'Already setup' }
        end

        # Step 1: Create Blastengine bulk delivery (if not already created)
        create_blastengine_delivery if @schedule.blastengine_delivery_id.blank?

        # Step 2: Fix user list
        create_recipient_records

        # Step 3: Generate and upload CSV
        upload_csv

        # Step 4: Set status to preparing (ConfirmImportWorker will handle the rest)
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

        @schedule.update!(blastengine_delivery_id: result['delivery_id'])
        Rails.logger.info("[SetupService] Created Blastengine delivery: #{result['delivery_id']}")
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

        return if users.empty?

        csv_content = CsvGenerator.new(users: users).generate

        result = @api.bulk_import_csv(
          delivery_id: @schedule.blastengine_delivery_id.to_i,
          csv_content: csv_content,
        )

        @schedule.update!(blastengine_job_id: result['job_id'])
        Rails.logger.info("[SetupService] CSV uploaded, job_id: #{result['job_id']}")
      end

      sig { returns(T.untyped) }
      def target_users
        return User.none if @delivery.user_tags.empty?

        User.joins(:tag_assignments)
            .where(tag_assignments: { user_tag_id: @delivery.user_tag_ids })
            .distinct
      end

      # Convert Liquid variables to Blastengine insert codes
      # {{ first_name }} -> __firstname__ (no underscore in key - Blastengine alphanumeric only)
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
