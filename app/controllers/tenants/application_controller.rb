module Tenants::ApplicationController
  extend ActiveSupport::Concern

  included do
    before_action :set_sentry_tenant_context
  end

  def set_sentry_tenant_context
    Raven.tags_context(tenant: Apartment::Tenant.current)
  end
end
