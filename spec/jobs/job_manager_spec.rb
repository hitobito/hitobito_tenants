
require 'spec_helper'

describe JobManager do
  let(:tenant_names) { ['test-tenant', 'hitobito', 'cool-people-foundation'] }
  let(:mail_job) { job_manager.send(:mail_jobs) }
  let(:tenant_jobs) { job_manager.send(:tenant_jobs) }

  subject(:job_manager) { JobManager.new }

  before do
    SeedFu.quiet = true
    ActiveRecord::Migration.suppress_messages do
      tenant_names.each do |name|
        Tenant.find_or_create_by(name: name)
        Apartment::Tenant.create(name)
      end
    end
    SeedFu.quiet = false
  end

  before do
    expect_any_instance_of(MailRelayJob).to receive(:configured?).and_return(true) # schedule regardless of config
  end

  describe '#schedule' do
    it 'schedules all jobs except mail for all tenants in tenant list' do
      job_manager.schedule

      expect(Delayed::Job.where("handler LIKE '%MailRelayJob%'").count).to eq(1)

      tenant_names.each do |tenant|
        tenant_jobs.each do |job|
          like_query = "'%#{job}\ncurrent_tenant: #{tenant}%'"
          expect(Delayed::Job.where("handler LIKE #{like_query}").count).to eq(1)
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

      Delayed::Job.where("handler LIKE '%current_tenant: hitobito%'").first.delete

      allow(job_manager).to receive(:puts)
      expect(job_manager.check).to eq(false)
    end
  end
end
