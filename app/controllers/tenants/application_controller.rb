module Tenants::ApplicationController
  extend ActiveSupport::Concern

  included do
    before_action :set_sentry_tenant_tag
  end

  def set_sentry_tenant_tag
    Sentry.configure_scope do |scope|
      scope.set_tags(tenant: Apartment::Tenant.current)
    end
  end
end
