# frozen_string_literal: true

#  Copyright (c) 2026, Puzzle ITC. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants

require "spec_helper"

describe Apartment::Elevators::MainSubdomain do
  let(:captured_hostnames) { [] }

  let(:app) do
    lambda do |_env|
      captured_hostnames << Settings.application.hostname
      [200, {}, ["OK"]]
    end
  end

  let(:elevator) { described_class.new(app) }

  before do
    @original_hostname = Settings.application.hostname
  end

  after do
    Settings.application.hostname = @original_hostname
  end

  it "sets Settings.application.hostname to the request host for a tenant" do
    env = Rack::MockRequest.env_for("http://test-tenant.hitobito.local/")

    status, _headers, _body = elevator.call(env)

    expect(status).to eq(200)
    expect(captured_hostnames.last).to eq("test-tenant.hitobito.local")
    expect(Settings.application.hostname).to eq(@original_hostname)
  end

  it "sets Settings.application.hostname to the admin host for the admin subdomain" do
    env = Rack::MockRequest.env_for("http://admin.hitobito.local/")

    status, _headers, _body = elevator.call(env)

    expect(status).to eq(200)
    expect(captured_hostnames.last).to eq("admin.hitobito.local")
  end

  it "redirects to the main domain for unknown subdomains" do
    env = Rack::MockRequest.env_for("http://unknown.hitobito.local/")

    status, headers, _body = elevator.call(env)

    expect(status).to eq(301)
    expect(headers["Location"]).to eq("http://hitobito.local")
  end
end
