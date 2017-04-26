# encoding: utf-8

#  Copyright (c) 2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'apartment/elevators/subdomain'

module Apartment
  module Elevators
    class MainSubdomain < Subdomain

      def initialize(app)
        @app = app
      end

      def call(env)
        request = Rack::Request.new(env)

        database = tenant_database(request.host)

        if database
          Apartment::Tenant.switch(database) { @app.call(env) }
        else
          [301, { 'Location' => "#{request.scheme}://#{Settings.tenants.domain}" }, []]
        end
      end

      def tenant_database(host)
        subdomain = main_subdomain(host).presence

        if ::Tenant.where(name: subdomain).exists?
          subdomain
        elsif subdomain == Settings.tenants.subdomains.admin
          Apartment::Tenant.default_tenant
        end
      end

      private

      def main_subdomain(host)
        if host.ends_with?(Settings.tenants.domain)
          host.gsub(/\.#{Settings.tenants.domain}$/, '')
        end
      end

    end
  end
end
