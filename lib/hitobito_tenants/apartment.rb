# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.


#
# Apartment Configuration
#
Apartment.configure do |config|

  # Add any models that you do not want to be multi-tenanted, but remain in the global (public)
  # namespace.
  # A typical example would be a Customer or Tenant model that stores each Tenant's information.
  #
  config.excluded_models = %w(Tenant Delayed::Job)

  # In order to migrate all of your Tenants you need to provide a list of Tenant names to Apartment.
  # You can make this dynamic by providing a Proc object to be called on migrations.
  # This object should yield either:
  # - an array of strings representing each Tenant name.
  # - a hash which keys are tenant names, and values custom db config (must contain all key/values
  #   required in database.yml)
  #
  # config.tenant_names = lambda{ Customer.pluck(:tenant_name) }
  # config.tenant_names = ['tenant1', 'tenant2']
  # config.tenant_names = {
  #   'tenant1' => {
  #     adapter: 'postgresql',
  #     host: 'some_server',
  #     port: 5555,
  #     database: 'postgres' # this is not the name of the tenant's db
  #                          # but the name of the database to connect to before creating the
  #                          # tenant's db. mandatory in postgresql.
  #   },
  #   'tenant2' => {
  #     adapter:  'postgresql',
  #     database: 'postgres' # this is not the name of the tenant's db
  #                          # but the name of the database to connect to before creating the
  #                          # tenant's db. mandatory in postgresql.
  #   }
  # }
  # config.tenant_names = lambda do
  #   Tenant.all.each_with_object({}) do |tenant, hash|
  #     hash[tenant.name] = tenant.db_configuration
  #   end
  # end
  #
  config.tenant_names = -> { Tenant.list.pluck(:name) }

  #
  # ==> PostgreSQL only options

  # Specifies whether to use PostgreSQL schemas or create a new database per Tenant.
  # The default behaviour is true.
  #
  # config.use_schemas = true

  # Apartment can be forced to use raw SQL dumps instead of schema.rb for creating new schemas.
  # Use this when you are using some extra features in PostgreSQL that can't be respresented in
  # schema.rb, like materialized views etc. (only applies with use_schemas set to true).
  # (Note: this option doesn't use db/structure.sql, it creates SQL dump by executing pg_dump)
  #
  # config.use_sql = false

  # There are cases where you might want some schemas to always be in your search_path
  # e.g when using a PostgreSQL extension like hstore.
  # Any schemas added here will be available along with your selected Tenant.
  #
  # config.persistent_schemas = %w{ hstore }

  # <== PostgreSQL only options
  #

  # By default, and only when not using PostgreSQL schemas, Apartment will prepend the environment
  # to the tenant name to ensure there is no conflict between your environments.
  # This is mainly for the benefit of your development and test environments.
  # Uncomment the line below if you want to disable this behaviour in production.
  #
  config.prepend_environment = false

  config.seed_after_create = true

  # Apartment supports parallelizing migrations into multiple threads when you
  # have a large number of tenants. By default, parallel migrations is turned
  # off. You can enable this by setting parallel_migration_threads to the
  # number of threads you want to use in your initializer.
  #
  # Keep in mind that because migrations are going to access the database, the
  # number of threads indicated here should be less than the pool size that
  # Rails will use to connect to your database.
  #
  # At the time of this writing, the pool-size is 20
  config.parallel_migration_threads = 15
end

module Apartment

  class << self

    def current_host_name
      "#{current_subdomain}.#{Settings.tenants.domain}"
    end

    def current_subdomain
      default_tenant? ? Settings.tenants.subdomains.admin : Apartment::Tenant.current
    end

    def default_tenant?
      Apartment::Tenant.current == Apartment::Tenant.default_tenant
    end

  end

end
