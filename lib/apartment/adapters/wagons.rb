#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require "apartment/adapters/abstract_adapter"

module Apartment
  module Adapters
    module Wagons
      extend ActiveSupport::Concern

      def create(tenant)
        create_tenant(tenant)
        migrate(tenant)
      end

      def migrate(tenant)
        switch(tenant) do
          migrate_core
          migrate_wagons
          Person.reset_column_information
          CustomContent::Translation.reset_column_information
          MailLog.reset_column_information
          seed # core
          seed_wagons
        end
      end

      private

      def migrate_core
        ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths,
          ActiveRecord::SchemaMigration)
          .migrate
      end

      def migrate_wagons
        wagons.each { |wagon| wagon.migrate(nil) }
      end

      def seed_wagons
        wagons.each { |wagon| wagon.load_seed }
      end

      def wagons
        @wagons ||= ::Wagons.all
      end
    end
  end
end

Apartment::Adapters::AbstractAdapter.send(:prepend, Apartment::Adapters::Wagons)
Apartment::Tenant.def_delegators :adapter, :migrate
