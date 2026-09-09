# frozen_string_literal: true

#  Copyright (c) 2026, Puzzle ITC. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants

module Tenants
  # Temporarily overrides Settings.application.hostname for the duration of a block.
  #
  # Used in the tenant-aware Rack elevator and Delayed::Job plugin so that
  # absolute URLs (e.g. for Pass QR codes or wallet web service URLs) are
  # generated with the correct tenant host.
  class ApplicationHost
    def self.with_tenant_hostname
      original = Settings.application.hostname
      Settings.application.hostname = Apartment.current_host_name
      yield
    ensure
      Settings.application.hostname = original
    end
  end
end
