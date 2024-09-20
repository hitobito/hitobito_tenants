# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

load File.expand_path('../../app_root.rb', __FILE__)
ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../../Gemfile', __FILE__)
ENV['RAILS_USE_TEST_GROUPS'] = 'true'
ENV['RAILS_HOST_NAME'] = 'hitobito.local'

require File.join(ENV['APP_ROOT'], 'spec', 'spec_helper.rb')

# Maintain test schema for core and wagon specs
#
# This normally checks for ActiveRecord::Migration.maintain_test_schema
# but since we disabled that in environments/test.rb we want to always run this here
ActiveRecord::Migration.suppress_messages do
  ActiveRecord::Migration.load_schema_if_pending!
  begin
    previous_seed_quietness = SeedFu.quiet
    SeedFu.quiet = true
    Wagons.all.each do |wagon|
      wagon.migrate
      wagon.load_seed
    end
  ensure
    SeedFu.quiet = previous_seed_quietness
  end
end

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[HitobitoTenants::Wagon.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_path = File.expand_path('../fixtures', __FILE__)

  config.before(:suite) do
    SeedFu.quiet = true
    ActiveRecord::Migration.suppress_messages do
      ['test-tenant', 'hitobito', 'cool-people-foundation'].each do |name|
        Tenant.find_or_create_by(name: name)
        Apartment::Tenant.create(name)
      end
    end
    SeedFu.quiet = false
  end

  config.before { Apartment.default_tenant = Apartment::Tenant.current }
end
