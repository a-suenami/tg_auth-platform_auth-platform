# typed: true

# Tenant.current.cookie_domain_remove_lengthの変更によって、古いdomainのcookieが残留指定しまうため、それらを削除するための特殊処理
module Authentication
  class DeleteOldSessionService < BaseService
    def execute(request:, response:)
      cookie_domain_remove_lengths = [0, 1, 2] - [T.must(Tenant.current).cookie_domain_remove_length]
      cookie_domain_remove_lengths.each do |cookie_domain_remove_length|
        response.set_cookie '_rails_app_session', {
          value: nil,
          expires: 1.year.ago,
          path: '/',
          secure: Rails.env.production?,
          httponly: true,
          domain: request.host.split('.').drop(cookie_domain_remove_length).join('.'),
        }
      end
    end
  end
end
