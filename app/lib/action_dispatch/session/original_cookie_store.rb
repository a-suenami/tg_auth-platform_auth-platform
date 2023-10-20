# typed: false

module ActionDispatch
  module Session
    class OriginalCookieStore < CookieStore
      private

      def set_cookie(request, session_id, cookie)
        if (request.path.start_with?('/api') || request.path.start_with?('/oauth')) && Tenant.current.present?
          cookie[:domain] = request.host.split('.').drop(Tenant.current.cookie_domain_remove_length).join('.')
          return cookie_jar(request)[@key] = cookie
        end
        super(request, session_id, cookie)
      end

      def cookie_jar(request)
        request.cookie_jar.signed_or_encrypted
      end
    end
  end
end
