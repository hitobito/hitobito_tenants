# encoding: utf-8

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module MailRelay
    module DynamicDomain

      def self.extended(base)
        base.singleton_class.alias_method_chain :mail_domain, :tenants
      end

      def mail_domain_with_tenants
        Apartment.current_host_name
      end

    end
  end
end
