# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class Tenant < ActiveRecord::Base

  validates_by_schema
  validates :name,
            uniqueness: true,
            exclusion: { in: :excluded_names },
            format: /\A[a-z0-9][a-z0-9-]{0,61}[a-z0-9]\z/

  scope :list, -> { order(:name) }

  def to_s
    name
  end

  def excluded_names
    Array(Settings.tenants.subdomains.excluded) <<
      Settings.tenants.subdomains.admin <<
      Apartment::Tenant.default_tenant
  end

end
