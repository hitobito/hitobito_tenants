#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module BaseJob
    extend ActiveSupport::Concern

    def delayed_jobs
      super.where(tenant: Apartment::Tenant.current)
    end
  end
end
