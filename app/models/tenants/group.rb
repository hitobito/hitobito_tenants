#  Copyright (c) 2025, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module Group
    extend ActiveSupport::Concern

    module ClassMethods
      def root_id
        root.id # do not cache, different values for different tenants
      end
    end
  end
end
