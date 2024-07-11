#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module DynamicUrlHost
    def default_url_options
      super.tap do |hash|
        hash[:host] = Apartment.current_host_name
      end
    end
  end
end
