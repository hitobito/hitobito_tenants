#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

namespace :tenants do
  desc "Lists all defined tenants"
  task list: :environment do
    puts Apartment.tenant_names
  end

  desc "Migrates all defined tenants to the latest version"
  task migrate: :environment do
    Apartment.tenant_names.each do |tenant|
      puts "Migrating tenant #{tenant}..."
      Apartment::Tenant.migrate(tenant)

      puts "Creating Search Index ..."
      Apartment::Tenant.switch(tenant) do
        SearchColumnBuilder.new.run
      end
    end
  end
end
