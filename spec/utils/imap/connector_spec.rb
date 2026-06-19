# frozen_string_literal: true

# Copyright (c) 2026, Hitobito AG. This file is part of
# hitobito_tenants and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_tenants.

require "spec_helper"
require "net/imap"

describe Imap::Connector do
  include Mails::ImapMailsSpecHelper

  let(:net_imap) { double(:net_imap) }
  let(:imap_connector) { Imap::Connector.new }

  let(:imap_fetch_data_1) { imap_fetch_data }
  let(:imap_fetch_data_2) { imap_fetch_data }

  let(:fetch_attributes) { %w[ENVELOPE UID RFC822] }

  let(:header_fetch_attribute) { "BODY.PEEK[HEADER.FIELDS (X-ORIGINAL-TO RECEIVED)]" }
  let(:current_tenant) { "themostimportant.hitobito.com" }
  let(:other_tenant) { "someotherinstance.hitobito.com" }

  let(:imap_config) do
    {
      address: "imap.example.com",
      imap_port: 42_993,
      enable_ssl: true,
      user_name: "catch-all@example.com",
      password: "holly-secret"
    }
  end

  before do
    allow(MailConfig).to receive(:legacy?).and_return(false)
    allow(MailConfig).to receive(:retriever_imap).and_return(imap_config)

    allow(Apartment).to receive(:current_host_name).and_return(current_tenant)

    expect(Net::IMAP).to receive(:new).and_return(net_imap)
    expect(net_imap).to receive(:login)
    expect(net_imap).to receive(:close)
    expect(net_imap).to receive(:disconnect)

    expect(net_imap).to receive(:select).with("INBOX")
    expect(net_imap).to receive(:uid_search).with(["ALL"]).and_return([41, 42])
  end

  describe "#fetch_mails" do
    it "returns only mails for the current tenant" do
      expect(net_imap).to receive(:uid_fetch)
        .with([41, 42], header_fetch_attribute)
        .and_return([
          header_fetch_data(41, x_original_to: "list@#{other_tenant}"),
          header_fetch_data(42, x_original_to: "list@#{current_tenant}")
        ])

      expect(net_imap).to receive(:uid_fetch)
        .with([42], fetch_attributes)
        .and_return([imap_fetch_data_1])

      result = imap_connector.fetch_mails(:inbox)

      expect(result[:total_count]).to eq(1)
      expect(result[:mails].map(&:uid)).not_to include "41"
    end
  end

  def header_fetch_data(uid, x_original_to: nil, received: nil)
    headers = []
    headers << "X-Original-To: #{x_original_to}" if x_original_to
    headers << "Received: #{received}" if received

    Net::IMAP::FetchData.new(uid, {
      "UID" => uid,
      "BODY[HEADER.FIELDS (X-ORIGINAL-TO RECEIVED)]" => "#{headers.join("\r\n")}\r\n"
    })
  end
end
