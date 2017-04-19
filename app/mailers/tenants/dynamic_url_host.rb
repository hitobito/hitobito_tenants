module Tenants
  module DynamicUrlHost

    def default_url_options
      super.tap do |hash|
        hash[:host] = Apartment.current_host_name
      end
    end

  end
end