#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

namespace :tenant do
  desc "Creates a new tenant with the given NAME"
  task create: :environment do
    name = ENV["NAME"]

    Tenant.create!(name: name)
    TenantCreatorJob.new(name).perform
  end

  desc "Drops the tenant with the given NAME"
  task drop: :environment do
    name = ENV["NAME"]

    Tenant.find_by!(name: name).destroy!
    TenantDestroyerJob.new(name).perform
  end
end

namespace :tenants do
  desc "Lists all defined tenants"
  task list: :environment do
    puts "Admin-Tenant: #{ENV["RAILS_ADMIN_SUBDOMAIN"]}"
    puts Apartment.tenant_names
  end

  desc "Migrates all defined tenants to the latest version"
  task migrate: :environment do
    list = Apartment.tenant_names
    list << ENV["RAILS_ADMIN_SUBDOMAIN"]
    tenants = list.compact_blank.uniq.sort

    tenants.each do |tenant|
      puts "Migrating tenant #{tenant}..."
      Apartment::Tenant.migrate(tenant)

      puts "Creating Search Index ..."
      Apartment::Tenant.switch(tenant) do
        SearchColumnBuilder.new.run
      end
    end
  end
end
