# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

class TenantDestroyerJob < BaseJob

  self.parameters = [:name]

  attr_reader :name

  def initialize(name)
    @name = name
  end

  def perform
    return if Tenant.where(name: name).exists?

    Apartment::Tenant.drop(name)
  end

end
