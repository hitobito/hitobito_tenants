#  Copyright (c) 2026, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

require "spec_helper"

describe "DelayedJob" do
  around do |example|
    original_adapter = ActiveJob::Base.queue_adapter
    ActiveJob::Base.queue_adapter = :delayed_job
    example.run
    ActiveJob::Base.queue_adapter = original_adapter
  end

  context "for BaseJob job" do
    let(:job) { BaseJob.new }

    it "sets tenant when enqueuing and switches to tenant when performing" do
      Apartment::Tenant.switch("cool-people-foundation") do
        job.enqueue!
      end

      job_instance = Delayed::Job.last

      expect(job_instance.tenant).to eq("cool-people-foundation")

      expect(Apartment::Tenant).to receive(:switch).with("cool-people-foundation")

      run_job(job_instance)
    end
  end

  context "for mailer job" do
    let(:job) { Person::UserImpersonationMailer.completed(Person.first, "tester") }

    it "sets tenant when enqueuing and switch to tenant when performing" do
      Apartment::Tenant.switch("cool-people-foundation") do
        job.deliver_later
      end

      job_instance = Delayed::Job.where("handler LIKE '%UserImpersonationMailer%'").last

      expect(job_instance.tenant).to eq("cool-people-foundation")

      expect(Apartment::Tenant).to receive(:switch).with("cool-people-foundation")

      run_job(job_instance)
    end
  end

  def run_job(job_instance)
    worker = Delayed::Worker.new

    # make sure we run the right job
    expect(worker).to receive(:reserve_job).and_return(job_instance)

    # the #run method does not run the callbacks..
    worker.send(:reserve_and_run_one_job)
  end
end
