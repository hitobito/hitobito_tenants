#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

namespace :app do
  namespace :license do
    task :config do
      @licenser = Licenser.new("hitobito_tenants",
        "hitobito AG",
        "https://github.com/hitobito/hitobito_tenants")
    end
  end
end
