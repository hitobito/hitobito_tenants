# frozen_string_literal: true

#  Copyright (c) 2026, Hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module MailEnvelopeHost
    def envelope_host_name(mail)
      host_from_x_original_to(mail) || host_from_received(mail)
    end

    def for_current_tenant?(mail)
      Apartment.current_host_name == envelope_host_name(mail)
    end

    private

    def host_from_x_original_to(mail)
      Array(mail.header["X-Original-To"]).first.to_s.split("@").last.presence
    end

    def host_from_received(mail)
      received = mail.received
      return unless received

      received = received.first if received.respond_to?(:first)
      received.info[/ for .*?[^\s<>]+@([^\s<>]+)/, 1]
    end
  end
end
