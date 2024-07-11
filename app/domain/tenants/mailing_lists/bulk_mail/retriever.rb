# frozen_string_literal: true

# Copyright (c) 2023, Hitobito AG. This file is part of
# hitobito_tenants and licensed under the Affero General Public License version 3
# or later. See the COPYING file at the top-level directory or at
# https://github.com/hitobito/hitobito_tenants.

module Tenants::MailingLists::BulkMail::Retriever
  extend ActiveSupport::Concern

  private

  def process_mail(mail_uid)
    imap_mail = fetch_mail(mail_uid)

    host = envelope_host_name(imap_mail)
    database = Apartment::Elevators::MainSubdomain.new(nil).tenant_database(host)
    if database
      Apartment::Tenant.switch(database) { super }
    else
      logger.info("Ignored email from #{imap_mail.sender_email} for unknown tenant #{host}")
    end
  end

  # The receiver subdomain that originally got this email.
  # Returns only the first part after the @ sign
  def envelope_host_name(imap_mail)
    receiver_host_from_sender_email(imap_mail) ||
      raise("Could not determine original receiver tenant for email:\n#{imap_mail.header}")
  end

  def receiver_host_from_sender_email(imap_mail)
    imap_mail.original_to.to_s.split("@", 2).last.presence
  end
end
