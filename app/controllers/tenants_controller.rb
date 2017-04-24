# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class TenantsController < SimpleCrudController

  self.permitted_attrs = [:name]

  after_create :create_tenant
  after_destroy :destroy_tenant

  private

  def list_entries
    super.list
  end

  def create_tenant
    TenantCreatorJob.new(entry.name).enqueue!
  end

  def destroy_tenant
    TenantDestroyerJob.new(entry.name).enqueue!
  end

end
