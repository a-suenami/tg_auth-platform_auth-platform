# typed: strict

module Deliveries
  module Concerns
    # Shared setup methods for Blastengine bulk delivery
    # Used by FixedTime::SetupService and Birthday::SetupService
    module BlastengineSetup
      extend T::Sig
      extend T::Helpers

      requires_ancestor { Kernel }

      # Convert Liquid variables to Blastengine insert codes
      # {{ first_name }} -> __firstname__
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

      # Create Blastengine bulk delivery and return delivery_id
      sig { params(delivery: Delivery, api: Blastengine::API).returns(Integer) }
      def create_blastengine_bulk_delivery(delivery:, api:)
        template = T.must(delivery.template)
        mail_version = template.template_mail_versions.published.order(created_at: :desc).first
        raise 'No published mail version' unless mail_version

        from_email = resolve_sender_email
        from_name = T.must(Tenant.current).name

        subject = render_with_insert_codes(mail_version.title)
        body = render_with_insert_codes(mail_version.body)

        result = api.bulk_begin(
          subject: subject,
          text_part: ActionView::Base.full_sanitizer.sanitize(body, tags: []),
          html_part: body,
          from_email: from_email,
          from_name: from_name,
        )

        result['delivery_id'].to_i
      end

      sig { returns(String) }
      def resolve_sender_email
        email = Tenant.current&.tenant_setting&.sender_email.presence
        raise 'Tenant sender_email not configured' unless email

        email
      end

      # Upload CSV to Blastengine and return job_id
      sig { params(delivery_id: Integer, users: T.untyped, api: Blastengine::API).returns(T.nilable(String)) }
      def upload_csv_to_blastengine(delivery_id:, users:, api:)
        return nil if users.empty?

        csv_content = CsvGenerator.new(users: users).generate

        result = api.bulk_import_csv(
          delivery_id: delivery_id,
          csv_content: csv_content,
        )

        result['job_id']&.to_s
      end
    end
  end
end
