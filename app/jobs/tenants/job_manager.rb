#  Copyright (c) 2024, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module Tenants
  module JobManager
    extend ActiveSupport::Concern

    def schedule
      return unless ActiveRecord::Base.connection.table_exists?("tenants")

      mail_jobs.new.schedule

      Tenant.find_each do |tenant|
        Apartment::Tenant.switch(tenant.name) do
          tenant_jobs.each do |job_class|
            job_class.new.schedule
          end
        end
      end
    end

    def check
      return unless ActiveRecord::Base.connection.table_exists?("tenants")

      scheduled = []
      missing = []

      Tenant.find_each do |tenant|
        tenant_jobs.each do |job_class|
          like_query = "'%#{job_class}\ncurrent_tenant: #{tenant}%'"
          if Delayed::Job.where("handler LIKE #{like_query}").present?
            scheduled << [job_class, tenant]
          else
            missing << [job_class, tenant]
          end
        end
      end

      if mail_jobs.new.scheduled?
        scheduled << [mail_jobs]
      else
        missing << [mail_jobs]
      end

      Rails.logger.debug { "Scheduled: #{scheduled.map { _1.join(": ") }}" } if scheduled.any?
      Rails.logger.debug { "Missing: #{missing.map { _1.join(": ") }}" } if missing.any?
      Rails.logger.debug "All expected jobs are scheduled." if missing.empty?

      missing.empty?
    end

    private

    def tenant_jobs
      jobs - [mail_jobs]
    end
  end
end
