# frozen_string_literal: true

#  Copyright (c) 2026, Hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module Imap
    module Connector
      extend ActiveSupport::Concern
      include Tenants::MailEnvelopeHost

      private

      def fetch_all_uids
        all_uids = super
        return [] if all_uids.empty?

        uid_headers = @imap.uid_fetch(all_uids, "BODY.PEEK[HEADER.FIELDS (X-ORIGINAL-TO RECEIVED)]")
        return [] if uid_headers.blank?

        uid_headers.select do |header|
          mail = Mail.read_from_string(header.attr["BODY[HEADER.FIELDS (X-ORIGINAL-TO RECEIVED)]"])
          for_current_tenant?(mail)
        end.map { |header| header.attr["UID"] }
      end
    end
  end
end
