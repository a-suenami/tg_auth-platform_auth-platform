# typed: true
# frozen_string_literal: true

class RootRedirectController < ApplicationController
  include ExpirableCookieUseable

  def index
    host = request.host
    host_with_port = request.host_with_port

    # ruler ドメイン（完全一致）
    if host_with_port == Settings.domains.ruler
      return redirect_to '/ruler'
    end

    # admin ドメイン（{tenant_id}.admin.{base} の形式）
    if host.include?('.admin.')
      return redirect_to '/admin'
    end

    # テナントドメイン（tenants.domain で明示的に確認）
    tenant = Tenant.find_by(domain: host)
    if tenant.present?
      if cookie_session[:current_user_id].present?
        redirect_to '/my'
      else
        redirect_to '/login'
      end
      return
    end

    # どれにも該当しない場合は 404
    raise ActionController::RoutingError, 'Not Found'
  end
end
