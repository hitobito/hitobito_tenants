# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe Tenant do

  context 'validations' do

    after { Settings.tenants.subdomains.excluded = nil }

    it 'allows regular subdomain' do
      Settings.tenants.subdomains.excluded = %w(www mail)
      expect(Tenant.new(name: 'any')).to be_valid
    end

    it 'allows dashes in subdomain' do
      expect(Tenant.new(name: 'any-thing')).to be_valid
    end

    it 'allows two character subdomains' do
      expect(Tenant.new(name: 'ok')).to be_valid
    end

    it 'does not allow one character subdomains' do
      expect(Tenant.new(name: 'a')).not_to be_valid
    end

    it 'does not allow dots in subdomain name' do
      expect(Tenant.new(name: 'foo.www')).not_to be_valid
    end

    it 'does not allow umlauts in subdomain name' do
      expect(Tenant.new(name: 'fäger')).not_to be_valid
    end

    it 'does not allow special characters in subdomain name' do
      expect(Tenant.new(name: 'f;er')).not_to be_valid
    end

    it 'does not allow dashes at the end of subdomain name' do
      expect(Tenant.new(name: 'hallo-')).not_to be_valid
    end

    it 'does not allow default tenant name' do
      expect(Tenant.new(name: Apartment::Tenant.default_tenant)).not_to be_valid
    end

    it 'does not allow excluded subdomain' do
      Settings.tenants.subdomains.excluded = %w(www mail)
      expect(Tenant.new(name: 'www')).not_to be_valid
    end

    it 'does not allow admin subdomain' do
      expect(Tenant.new(name: Settings.tenants.subdomains.admin)).not_to be_valid
    end

    it 'does not allow admin subdomain with excluded subdomains' do
      Settings.tenants.subdomains.excluded = %w(www mail)
      expect(Tenant.new(name: 'admin')).not_to be_valid
    end

  end

end