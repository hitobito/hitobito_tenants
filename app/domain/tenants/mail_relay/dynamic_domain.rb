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