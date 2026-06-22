#  Copyright (c) 2026, Puzzle ITC. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require "spec_helper"

describe Wallets::AppleWallet::PassService do
  let(:person) { Fabricate(:person) }
  let(:definition) { Fabricate(:pass_definition) }

  let(:pass) do
    Fabricate(:pass, person: person, pass_definition: definition,
      state: :eligible, valid_from: Date.current)
  end
  let(:installation) { Fabricate(:wallets_pass_installation, pass: pass, wallet_type: :apple) }

  let(:client) { instance_double(Wallets::AppleWallet::PkpassGenerator) }

  subject(:service) do
    described_class.new(installation, client: client)
  end

  before do
    allow(Wallets::AppleWallet::Config).to receive(:pass_type_identifier).and_return("pass.com.example.test")
    allow(Wallets::AppleWallet::Config).to receive(:team_identifier).and_return("ABCDE12345")
    allow(Wallets::AppleWallet::Config).to receive(:web_service_url).and_return("https://example.com/api/apple")
  end


  it "includes tenant in id prefix" do
    Apartment::Tenant.switch("cool-people-foundation") do
      expect(service.pass_data[:serialNumber]).to eq("hitobito.test.cool-people-foundation.#{installation.id}")
    end
  end
end
