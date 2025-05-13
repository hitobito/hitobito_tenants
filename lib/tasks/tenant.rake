# frozen_string_literal: true

#  Copyright (c) 2025-2025, Puzzle ITC. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

namespace :tenant do
  desc "Select a Tenant"
  task :select, [:tenant] => [:environment] do |_t, args|
    tenant = args.fetch(:tenant)

    if Apartment.tenant_names.include?(tenant)
      @tenant = tenant
      warn "Will select tenant #{@tenant} in following tasks..."
    else
      @tenant = nil
      abort "Please select a valid tenant. See rake tenants:list"
    end
  end

  desc "Setup admin-user for tenant"
  task :admin_user, [:first_name, :last_name, :email] => [:environment] do |_t, args|
    abort "Select a tenant with rake tenant:select[tenant_name] first" if @tenant.nil?

    email = args.fetch(:email)
    first_name = args.fetch(:first_name)
    last_name = args.fetch(:last_name)

    Apartment::Tenant.switch(@tenant) do
      puts "#{@tenant} -> #{email} (#{first_name} #{last_name})"
      # person = Person.create(first_name:, last_name:, email:)
      # puts [person.id, person].join(' ')
    end
  end

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
