# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module BaseJob

    extend ActiveSupport::Concern

    included do
      alias_method_chain :initialize, :tenants
      alias_method_chain :before, :tenants
      alias_method_chain :parameters, :tenants
    end

    def initialize_with_tenants
      initialize_without_tenants
      @current_tenant = Apartment::Tenant.current
    end

    def before_with_tenants(delayed_job)
      before_without_tenants(delayed_job)
      Apartment::Tenant.switch!(@current_tenant)
    end

    private

    def parameters_with_tenants
      parameters_without_tenants.tap do |hash|
        hash[:current_tenant] = @current_tenant
      end
    end

  end
end
