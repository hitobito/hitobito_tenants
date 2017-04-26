# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe TenantAbility do

  subject { ability }
  let(:ability) { Ability.new(user.reload) }


  context 'as global admin' do
    let(:user) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: groups(:top_group)).person }

    it { is_expected.to be_able_to(:index, Tenant) }
    it { is_expected.to be_able_to(:create, Tenant.new) }
    it { is_expected.to be_able_to(:destroy, Tenant.new) }
    it { is_expected.not_to be_able_to(:update, Tenant.new) }
  end

  context 'as global root' do
    let(:user) { Person.find_by(email: Settings.root_email) }

    it { is_expected.to be_able_to(:index, Tenant) }
    it { is_expected.to be_able_to(:create, Tenant.new) }
    it { is_expected.to be_able_to(:destroy, Tenant.new) }
  end

  context 'as tenant admin' do
    before { allow(Apartment::Tenant).to receive(:current).and_return('other') }

    let(:user) { Fabricate(Group::TopGroup::Leader.name.to_sym, group: groups(:top_group)).person }

    it { is_expected.not_to be_able_to(:index, Tenant) }
    it { is_expected.not_to be_able_to(:create, Tenant.new) }
    it { is_expected.not_to be_able_to(:destroy, Tenant.new) }
  end

  context 'as tenant root' do
    before { allow(Apartment::Tenant).to receive(:current).and_return('other') }

    let(:user) { Person.find_by(email: Settings.root_email) }

    it { is_expected.not_to be_able_to(:index, Tenant) }
    it { is_expected.not_to be_able_to(:create, Tenant.new) }
    it { is_expected.not_to be_able_to(:destroy, Tenant.new) }
  end

end