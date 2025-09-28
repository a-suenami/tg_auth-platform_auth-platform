# typed: strict
# frozen_string_literal: true

module API
  class ApplicationController < ActionController::API
    extend T::Sig
    include API::ExceptionRescuable
    include ExpirableCookieUseable
    before_action :set_tenant


    # Blueprinterヘルパーメソッド
    sig { params(blueprint_class: T.class_of(Blueprinter::Base), object: T.untyped, options: T.untyped).void }
    def render_blueprint(blueprint_class, object, options = {})
      render json: blueprint_class.render_as_hash(object, options)
    end

    sig { params(blueprint_class: T.class_of(Blueprinter::Base), collection: T.untyped, options: T.untyped).void }
    def render_blueprint_collection(blueprint_class, collection, options = {})
      render json: blueprint_class.render_as_hash(collection, options)
    end

    private

    sig { returns(T.nilable(Tenant)) }
    def set_tenant
      RequestStore.store[:current_tenant_domain] = request.host || '-'
      Tenant.current
    end
  end
end
