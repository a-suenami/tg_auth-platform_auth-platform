module ActionDispatch
  module Session
    class OriginalCookieStore < CookieStore
      private
      def set_cookie(request, session_id, cookie)
        if request.path.start_with?('/api') || request.path.start_with?('/oauth')
          if Tenant.current.present? && Tenant.current.set_parent_domain_cookie
            cookie[:domain] = request.host.split('.').drop(1).join('.')
            return cookie_jar(request)[@key] = cookie
          end
        end
        return super(request, session_id, cookie)
      end

      def cookie_jar(request)
        request.cookie_jar.signed_or_encrypted
      end
    end
  end
end
