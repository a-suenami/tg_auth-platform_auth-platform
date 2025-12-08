# typed: false

module Templates
  module Mail
    class PreviewService < BaseService
      def call(body:, title: nil, sample_data: {})
        return { success: false, error: 'メール本文が必要です' } if body.blank?

        begin
          template = Liquid::Template.parse(body)
          merged_data = AdminArea::TemplatesHelper::DEFAULT_SAMPLE_DATA.merge(sample_data.transform_keys(&:to_s))

          # Auto-generate full_name from first_name + last_name
          merged_data['full_name'] = "#{merged_data['last_name']} #{merged_data['first_name']}".strip

          context = Liquid::Context.new(merged_data)
          rendered = template.render(context)

          # Sanitize for safe HTML display
          sanitized = sanitize_html(rendered)

          {
            success: true,
            html: sanitized,
            raw: rendered,
            title: title,
          }
        rescue Liquid::SyntaxError => e
          { success: false, error: "テンプレート構文エラー: #{e.message}" }
        rescue StandardError => e
          { success: false, error: "プレビューエラー: #{e.message}" }
        end
      end

      private

      def sanitize_html(html)
        ActionController::Base.helpers.sanitize(
          html,
          tags: AdminArea::TemplatesHelper::ALLOWED_EMAIL_TAGS,
          attributes: AdminArea::TemplatesHelper::ALLOWED_EMAIL_ATTRIBUTES,
        )
      end
    end
  end
end
