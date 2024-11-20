# frozen_string_literal: true

# We do not have feature specs but still have to redefine that task in order to clear depdencies such as
# ** Execute app:db:load_config
# ** Execute app:db:test:prepare
# ...
# ** Invoke app:db:test:load_schema (first_time)
# ** Invoke app:db:test:purge
# ** Execute app:db:test:load_schema
#
# which results in missing collation when running specs
# see core (hitobito/hitobito#2d9b16f4b, hitobito/hitobito#87696168d)
#
namespace :spec do
  RSpec::Core::RakeTask.new(:without_features) do |t|
    t.pattern = "./spec/**/*_spec.rb"
    t.rspec_opts = "--tag ~type:feature"
  end

  task all: ["spec:features", "spec:without_features"]
end
