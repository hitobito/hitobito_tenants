# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module HitobitoTenants
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    rake_tasks do
      load 'hitobito_tenants/tenants.rake'
    end

    config.to_prepare do
    end

    initializer 'tenants.configure_apartment' do |app|
      require 'hitobito_tenants/apartment'
    end

    initializer 'tenants.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

  end
end
