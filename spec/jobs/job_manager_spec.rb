#  Copyright (c) 2026, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require 'spec_helper'

describe JobManager do
  let(:tenant_names) { ['test-tenant', 'hitobito', 'cool-people-foundation'] }
  let(:mail_job) { job_manager.send(:mail_jobs) }
  let(:tenant_jobs) { job_manager.send(:tenant_jobs) }

  subject(:job_manager) { JobManager.new }


  before do
    expect_any_instance_of(MailRelayJob).to receive(:configured?).and_return(true) # schedule regardless of config
  end

  describe '#schedule' do
    it 'schedules all jobs except mail for all tenants in tenant list' do
      job_manager.schedule

      expect(Delayed::Job.where("handler LIKE '%MailRelayJob%'").count).to eq(1)

      tenant_names.each do |tenant|
        tenant_jobs.each do |job|
          expect(Delayed::Job.where("handler LIKE '%#{job}%'").where(tenant: tenant).count).to eq(1)
        end
      end
    end
  end

  describe '#check' do
    it 'returns true if everything is scheduled' do
      job_manager.schedule

      allow(job_manager).to receive(:puts)
      expect(job_manager.check).to eq(true)
    end

    it 'returns false if mail job is missing' do
      job_manager.schedule

      Delayed::Job.where("handler LIKE '%MailRelayJob%'").first.delete

      allow(job_manager).to receive(:puts)
      expect(job_manager.check).to eq(false)
    end

    it 'returns false if single tenant job is missing' do
      job_manager.schedule

      Delayed::Job.where(tenant: "hitobito").last.delete

      allow(job_manager).to receive(:puts)
      expect(job_manager.check).to eq(false)
    end
  end
end
