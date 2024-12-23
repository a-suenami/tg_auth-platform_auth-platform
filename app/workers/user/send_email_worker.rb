# typed: true

class User
  class SendEmailWorker < ApplicationController
    include Sidekiq::Worker
    extend T::Sig
    include Sidekiq::Job
    sidekiq_options queue: :low_priority, retry: 10, unique_for: 10.minutes, unique_until: :success

    sig { params(tenant_id: String, template_type: String, params: Hash, send_to: String).void }
    def perform(tenant_id, template_type, params, send_to)
      Tenant.current_domain = Tenant.find(tenant_id).domain
      throttle = T.let(Sidekiq::Limiter.window('blastengine', Settings.blastengine.rate_limit, :second, wait_timeout: 6.hours.to_i), Sidekiq::Limiter::Window)

      throttle.within_limit do
        email_template = EmailTemplate.find_by!(template_type:)
        liquid_template = Liquid::Template.parse(email_template.body)

        # Liquid標準でキーが文字列なため、変換
        context = Liquid::Context.new(params)

        Blastengine::API.new.send_email(
          send_to:,
          subject: email_template.subject,
          body: liquid_template.render(context),
          from_email: Tenant.current&.tenant_setting&.sender_email,
          from_name: Tenant.current&.name,
        )
      end
    end
  end
end
