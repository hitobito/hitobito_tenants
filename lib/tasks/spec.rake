# frozen_string_literal: true

# We do not have feature specs but still have to redefine that task in order to clear task's
# prerequisites, in particular db:schema:load which results in missing collation when running specs
# see core (hitobito/hitobito#2d9b16f4b, hitobito/hitobito#87696168d)
#
# Schema is prepared in seperate job on CI
#
# ** Execute app:db:load_config
# ** Execute app:db:test:prepare
# ...
# ** Invoke app:db:test:load_schema (first_time)
# ** Invoke app:db:test:purge
# ** Execute app:db:test:load_schema
#
#
namespace :spec do
  Rake::Task[:spec].clear_prerequisites
  task all: "spec"
  task without_features: "spec"
end
