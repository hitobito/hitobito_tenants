# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

namespace :tenant do
  desc 'Creates a new tenant with the given NAME'
  task :create => :environment do
    name = ENV['NAME']
    if Tenant.where(name: name).exists?
      say "Tenant #{name} already exists!"
      exit 1
    end

    Apartment::Tenant.create(name)
    Tenant.create!(name: name)
  end

  desc 'Drops the tenant with the given NAME'
  task :drop => :environment do
    name = ENV['NAME']
    unless Tenant.where(name: name).exists?
      say "Tenant #{name} does not exist!"
    end

    Apartment::Tenant.drop(name)
    Tenant.find_by(name: name).destroy!
  end
end

namespace :tenants do

  desc 'Lists all defined tenants'
  task :list => :environment do
    say Apartment.tenant_names
  end

  desc 'Migrates all defined tenants to the latest version'
  task :migrate => :environment do
    Apartment.tenant_names.each do |tenant|
      say "Migrating tenant #{tenant}..."
      Apartment::Tenant.migrate(tenant)
    end
  end

end