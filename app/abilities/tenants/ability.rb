# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module Ability
    def define_root_abilities
      super

      unless Apartment::Tenant.current == Apartment::Tenant.default_tenant
        cannot :manage, Tenant
      end
    end
  end
end
