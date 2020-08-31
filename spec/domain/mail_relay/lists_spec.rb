# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe MailRelay::Lists do

  let(:message) do
    mail = Mail.new(File.read(Rails.root.join('spec', 'fixtures', 'email', 'regular.eml')))
    mail.header['X-Original-To'] = original_to
    mail.from = from
    mail
  end

  let(:original_to) { "#{list.mail_name}@#{envelope_host}.#{Settings.tenants.domain}" }
  let(:from) { people(:top_leader).email }

  let(:bll)  { people(:bottom_leader) }
  let(:bgl1) { Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_one)).person }
  let(:bgl2) { Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_two)).person }
  let(:ind)  { Fabricate(:person) }

  let(:list) { mailing_lists(:leaders) }

  let(:subscribers) { [ind, bll, bgl1] }

  let(:relay) { MailRelay::Lists.new(message) }

  subject { relay }

  before { create_individual_subscribers }

  context 'to admin tenant' do

    let(:envelope_host) { 'admin' }

    it 'relays' do
      expect(Apartment::Tenant).to receive(:switch).with(Apartment::Tenant.default_tenant).and_yield

      expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
      expect(last_email.header['List-Id'].to_s).to eq('leaders.admin.hitobito.local')
      expect(last_email.sender).to eq('leaders-bounces+top_leader=example.com@admin.hitobito.local')
    end

  end

  context 'to custom tenant' do

    let(:envelope_host) { 'test-tenant' }

    it 'relays' do
      expect(Apartment::Tenant).to receive(:switch).with('test-tenant').and_yield
      expect(Apartment::Tenant).to receive(:current).and_return('test-tenant').at_least(:once)

      expect { subject.relay }.to change { ActionMailer::Base.deliveries.size }.by(1)

      expect(last_email.smtp_envelope_to).to match_array(subscribers.collect(&:email))
      expect(last_email.header['List-Id'].to_s).to eq('leaders.test-tenant.hitobito.local')
      expect(last_email.sender).to eq('leaders-bounces+top_leader=example.com@test-tenant.hitobito.local')
    end

  end

  context 'to non-existing tenant' do

    let(:envelope_host) { 'test-tenant' }

    it 'does not do anything' do
      expect_any_instance_of(Apartment::Elevators::MainSubdomain).to receive(:tenant_database).and_return(nil)
      expect { subject.relay }.not_to change { ActionMailer::Base.deliveries.size }
    end

  end


  def create_individual_subscribers
    # single subscription
    sub = list.subscriptions.new
    sub.subscriber = ind
    sub.save!
    # excluded subscription
    sub = list.subscriptions.new
    sub.subscriber = bgl2
    sub.excluded = true
    sub.save!

    # create people
    subscribers
  end
end
