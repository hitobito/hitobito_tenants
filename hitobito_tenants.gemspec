$LOAD_PATH.push File.expand_path("../lib", __FILE__)

# Maintain your wagon's version:
require "hitobito_tenants/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name = "hitobito_tenants"
  s.version = HitobitoTenants::VERSION
  s.authors = ["Pascal Zumkehr", "Matthias Viehweger"]
  s.email = ["zumkehr@puzzle.ch", "viehweger@puzzle.ch"]
  s.homepage = "http://hitobito.ch"
  s.summary = "Multiple tenants for hitobito"
  s.description = "Add database multi-tenancy to hitobito"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["Rakefile"]

  s.add_dependency "ros-apartment", "~> 3.2.0"
end
