# frozen_string_literal: true

#  Copyright (c) 2012-2020, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module MailRelay
    module Lists

      extend ActiveSupport::Concern


      def relay
        host = envelope_host_name
        database = Apartment::Elevators::MainSubdomain.new(nil).tenant_database(host)
        if database
          Apartment::Tenant.switch(database) { super }
        else
          logger.info("Ignored email from #{sender_email} for unknown tenant #{host}")
        end
      end

      private

      def envelope_sender
        self.class.personal_return_path(envelope_receiver_name, sender_email, mail_domain)
      end

      # The receiver subdomain that originally got this email.
      # Returns only the first part after the @ sign
      def envelope_host_name
        receiver_host_from_x_original_to_header ||
        receiver_host_from_received_header ||
          raise("Could not determine original receiver tenant for email:\n#{message.header}")
      end

      def receiver_host_from_x_original_to_header
        first_header('X-Original-To').to_s.split('@').last.presence
      end

      # Heuristic method to find actual receiver of the message.
      # May return nil if could not determine.
      def receiver_host_from_received_header
        if (received = message.received)
          received = received.first if received.respond_to?(:first)
          received.info[/ for .*?[^\s<>]+@([^\s<>]+)/, 1]
        end
      end

      def mail_domain
        Apartment.current_host_name
      end

    end
  end
end
