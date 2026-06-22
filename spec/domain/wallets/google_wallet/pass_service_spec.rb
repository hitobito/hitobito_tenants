# encoding: utf-8

#  Copyright (c) 2012-2026, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require "spec_helper"

describe Wallets::GoogleWallet::PassService do
  let(:person) { Fabricate(:person) }
  let(:definition) { Fabricate(:pass_definition) }

  let(:issuer_id) { "42" }
  let(:client) { instance_double(Wallets::GoogleWallet::Client) }
  let(:pass) do
    Fabricate(:pass,
      person: person,
      pass_definition: definition,
      state: :eligible,
      valid_from: Date.current)
  end
  let(:pass_installation) { Fabricate(:wallets_pass_installation, pass:, wallet_type: :google) }

  subject(:service) { described_class.new(pass_installation, client: client) }

  before do
    allow(Wallets::GoogleWallet::Config).to receive(:issuer_id).and_return(issuer_id)
    allow(Settings.application).to receive(:logo).and_return(nil)
  end

  describe "#create_or_update" do
    let(:create_or_update_payload) do
      captured_payload = nil
      allow(client).to receive(:create_or_update_object) { |p, **_| captured_payload = p }
      allow(client).to receive(:create_class)
      service.create_or_update
      captured_payload
    end


    let(:prefix) { "#{issuer_id}.hitobito.test.cool-people-foundation" }

    it "includes tenant in id prefix" do
      Apartment::Tenant.switch("cool-people-foundation") do
        expect(create_or_update_payload[:id]).to eq("#{prefix}.pass.#{service.pass.id}.#{pass_installation.id}")
        expect(create_or_update_payload[:classId]).to eq("#{prefix}.class.#{definition.id}")
      end
    end
  end
end
