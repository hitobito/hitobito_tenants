#  Copyright (c) 2026, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class TenantDelayedJobPlugin < Delayed::Plugin
  callbacks do |lifecycle|
    # save current tenant before enqueuing the job
    lifecycle.before :enqueue do |job|
      job.tenant = Apartment::Tenant.current
    end

    lifecycle.around :perform do |worker, job, *args, &block|
      # Switch to the saved tenant, occurs before deserializing this job
      Apartment::Tenant.switch(job.tenant) do
        block.call(worker, job, *args)
      end
    end
  end
end

Delayed::Worker.plugins << TenantDelayedJobPlugin
