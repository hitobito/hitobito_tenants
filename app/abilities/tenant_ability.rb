# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class TenantAbility < AbilityDsl::Base

  on(Tenant) do
    class_side(:index).if_global_admin
    # The name may not be updated
    permission(:admin).may(:create, :destroy).if_global
  end

  def if_global_admin
    if_global && if_admin
  end

  def if_global
    Apartment::Tenant.current == Apartment::Tenant.default_tenant
  end

end
