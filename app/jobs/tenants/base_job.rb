# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module BaseJob

    extend ActiveSupport::Concern

    def initialize
      super
      @current_tenant = Apartment::Tenant.current
    end

    def before(delayed_job)
      super(delayed_job)
      Apartment::Tenant.switch!(@current_tenant)
    end

    private

    def parameters
      super.tap do |hash|
        hash[:current_tenant] = @current_tenant
      end
    end

  end
end
