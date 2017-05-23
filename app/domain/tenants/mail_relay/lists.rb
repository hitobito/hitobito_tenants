# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module MailRelay
    module Lists

      extend ActiveSupport::Concern

      included do
        singleton_class.alias_method_chain :mail_domain, :tenants
        alias_method_chain :relay, :tenants
        alias_method_chain :receiver_from_x_header, :tenants
      end

      def relay_with_tenants
        host = "#{envelope_host_name}.#{Settings.tenants.domain}"
        database = Apartment::Elevators::MainSubdomain.new(nil).tenant_database(host)
        if database
          Apartment::Tenant.switch(database) { relay_without_tenants }
        else
          logger.info("Ignored email from #{sender_email} " \
                      "for unknown tenant #{host}")
        end
      end

      private

      # Try to read the envelope receiver from the given x header.
      # The header has the form `mail_name[+suffix]+subdomain`
      def receiver_from_x_header_with_tenants
        receiver_x_header_parts.first
      end

      # The receiver subdomain that originally got this email.
      # Returns only the first part after the @ sign
      def envelope_host_name
        receiver_host_from_x_header ||
          receiver_host_from_received_header ||
          raise("Could not determine original receiver tenant for email:\n#{message.header}")
      end

      # Try to read the envelope receiver from the given x header
      # The header has the form `mail_name[+suffix]+subdomain`
      def receiver_host_from_x_header
        receiver_x_header_parts.last
      end

      def receiver_x_header_parts
        field = message.header[receiver_header]
        field ? field.to_s.rpartition('+') : []
      end

      # Heuristic method to find actual receiver of the message.
      # May return nil if could not determine.
      def receiver_host_from_received_header
        if (received = message.received)
          received = received.first if received.respond_to?(:first)
          received.info[/ for .*?[^\s<>]+@([^\s<>]+)/, 1]
        end
      end

      module ClassMethods

        def mail_domain_with_tenants
          Apartment.current_host_name
        end

      end

    end
  end
end
