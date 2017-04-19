module Tenants
  module BaseJob

    extend ActiveSupport::Concern

    included do
      alias_method_chain :initialize, :tenants
      alias_method_chain :before, :tenants
      alias_method_chain :parameters, :tenants
    end

    def initialize_with_tenants
      initialize_without_tenants
      @tenant = Apartment::Tenant.current
    end

    def before_with_tenants(delayed_job)
      before_without_tenants(delayed_job)
      puts 'Processing job for tenant ' + @tenant
      Apartment::Tenant.switch!(@tenant)
    end

    private

    def parameters_with_tenants
      parameters_without_tenants.tap do |hash|
        hash[:tenant] = @tenant
      end
    end

  end
end