# frozen_string_literal: true

#  Copyright (c) 2012-2020, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module MailRelay
    module Lists
      extend ActiveSupport::Concern
      include Tenants::MailEnvelopeHost

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

      def envelope_host_name
        host_from_x_original_to(message) || host_from_received(message) ||
          raise("Could not determine original receiver tenant for email:\n#{message.header}")
      end

      def mail_domain
        URI("https://#{Apartment.current_host_name}").hostname
      end
    end
  end
end
