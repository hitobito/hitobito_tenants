# encoding: utf-8

#  Copyright (c) 2023, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe MailingLists::BulkMail::Retriever do
  include Mails::ImapMailsSpecHelper

  let(:retriever) { described_class.new }
  let(:imap_connector) { instance_double(Imap::Connector) }
  let(:mailing_list) { mailing_lists(:leaders) }
  let(:imap_mail_validator) { instance_double(MailingLists::BulkMail::ImapMailValidator) }
  let(:imap_mail) { build_imap_mail(42) }
  let(:dispatch_job) { instance_double(Messages::DispatchJob) }

  let(:original_to) do
    "#{list.mail_name}@#{envelope_host}.#{Settings.tenants.domain.gsub(/:[0-9]+$/, '')}"
  end
  let(:from) { people(:top_leader).email }

  let(:bll)  { people(:bottom_leader) }
  let(:bgl1) do
    Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_one)).person
  end
  let(:bgl2) do
    Fabricate(Group::BottomGroup::Leader.name.to_sym, group: groups(:bottom_group_one_two)).person
  end
  let(:ind)  { Fabricate(:person) }

  let(:list) { mailing_lists(:leaders) }

  let(:subscribers) { [ind, bll, bgl1] }

  subject { retriever }

  before do
    create_individual_subscribers
    allow(retriever).to receive(:validator).and_return(imap_mail_validator)
    allow(retriever).to receive(:imap).and_return(imap_connector)
    allow(imap_connector).to receive(:fetch_mail_by_uid).with(42, :inbox).and_return(imap_mail)
    allow(imap_connector).to receive(:fetch_mail_uids).with(:inbox).and_return([42])
    allow(imap_connector).to receive(:delete_by_uid).with(42, :inbox).and_return(nil)
    allow(imap_mail_validator).to receive(:valid_mail?).and_return(true)
    allow(imap_mail_validator).to receive(:processed_before?).and_return(false)
    allow(imap_mail_validator).to receive(:sender_allowed?).and_return(true)
    allow(imap_mail_validator).to receive(:mail_too_big?).and_return(false)
    allow(imap_mail_validator).to receive(:return_path_header_nil?).and_return(false)
  end

  context 'to admin tenant' do

    let(:envelope_host) { 'admin' }

    it 'retrieves and schedules sender job' do
      expect(Apartment::Tenant).to receive(:switch).with(Apartment::Tenant.default_tenant).ordered.and_yield
      expect(Message::BulkMail).to receive(:create!).ordered.and_call_original
      expect(MailLog).to receive(:create!).ordered.and_call_original
      expect(Messages::DispatchJob).to receive(:new).and_return(dispatch_job).ordered
      expect(dispatch_job).to receive(:enqueue!).ordered.and_return nil

      expect { subject.perform }.to change { MailLog.count }.by(1)
    end

  end

  context 'to custom tenant' do

    let(:envelope_host) { 'test-tenant' }

    it 'retrieves and schedules sender job' do
      expect(Apartment::Tenant).to receive(:switch).with('test-tenant').ordered.and_yield
      expect(Message::BulkMail).to receive(:create!).ordered.and_call_original
      expect(MailLog).to receive(:create!).ordered.and_call_original
      expect(Messages::DispatchJob).to receive(:new).and_return(dispatch_job).ordered
      expect(dispatch_job).to receive(:enqueue!).and_return(nil).ordered

      expect { subject.perform }.to change { MailLog.count }.by(1)
    end

  end

  context 'to non-existing tenant' do

    let(:envelope_host) { 'unknown-tenant' }

    it 'does not do anything' do
      expect(Messages::DispatchJob).not_to receive(:new)
      expect { subject.perform }.not_to(change { MailLog.count })
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

  def build_imap_mail(uid)
    mail = Imap::Mail.new
    allow(mail).to receive(:uid).and_return(uid)
    allow(mail).to receive(:subject).and_return('Mail 42')
    allow(mail).to receive(:original_to).and_return(original_to)
    allow(mail).to receive(:hash).and_return('abcd42')
    allow(mail).to receive(:sender_email).and_return(from)

    imap_mail = Mail.read_from_string(File.read(Rails.root.join('spec', 'fixtures', 'email',
                                                                'list.eml')))
    allow(mail).to receive(:mail).and_return(imap_mail)
    mail
  end
end
