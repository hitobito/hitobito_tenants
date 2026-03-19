#  Copyright (c) 2026, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class AddTenantToDelayedJobs < ActiveRecord::Migration[6.1]
  def up
    add_column :delayed_jobs, :tenant, :string

    Delayed::Job.reset_column_information

    # make sure we dont have any jobs scheduled without the tenant set
    Delayed::Job.delete_all
  end

  def down
    remove_column :delayed_jobs, :tenant
  end
end
