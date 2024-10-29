# frozen_string_literal: true

require "apartment/adapters/abstract_adapter"
require "apartment/tenant"

module Apartment
  module Tenant
    def self.nulldb_adapter(config)
      Adapters::NulldbAdapter.new(config)
    end
  end

  module Adapters
    class NulldbAdapter < AbstractAdapter
      def create(tenant)
        true
      end

      def drop(tenant)
        true
      end

      def switch!(tenant = nil)
        true
      end
    end
  end
end
