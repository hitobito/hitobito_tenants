# frozen_string_literal: true

#  Copyright (c) 2024-2024, verband. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module Sortable
    extend ActiveSupport::Concern

    included do
      ::Sortable::Prepends.remove_method(:model_table_name)
    end

    def model_table_name
      model_class.table_name.delete_prefix("#{Apartment::Tenant.default_tenant}.")
    end
  end
end
