# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe TenantsController, type: :controller do

  class << self
    def it_should_redirect_to_show
      it { is_expected.to redirect_to tenants_path(returning: true) }
    end
  end

  let!(:test_entry) { Tenant.create!(name: 'tenant1') }
  let(:test_entry_attrs) do
    { name: 'tenant-t' }
  end

  before { sign_in(people(:top_leader)) }

  before do
    allow_any_instance_of(TenantCreatorJob).to receive(:enqueue!)
    allow_any_instance_of(TenantDestroyerJob).to receive(:enqueue!)
  end

  include_examples 'crud controller',
                   skip: [%w(show), %w(edit), %w(update), %w(create html invalid)]

  describe 'PUT update' do
    it 'is not allowed' do
      expect do
        put :update, params: { id: test_entry.id }
      end.to raise_error(CanCan::AccessDenied)
    end
  end

end
