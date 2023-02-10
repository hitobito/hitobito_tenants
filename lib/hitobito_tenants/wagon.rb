# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2012-2017, hitobito AG. This file is part of
#  hitobito_tenants and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito_tenants.

module HitobitoTenants
  class Wagon < Rails::Engine
    include Wagons::Wagon

    # Set the required application version.
    app_requirement '>= 0'

    rake_tasks do
      load 'hitobito_tenants/tenants.rake'
    end

    config.to_prepare do
      ApplicationController.include Tenants::ApplicationController
      MailingList.prepend Tenants::MailingList
      Person::PictureUploader.prepend Tenants::Uploader::DynamicDir
      Event::AttachmentUploader.prepend Tenants::Uploader::DynamicDir
      Group::LogoUploader.prepend Tenants::Uploader::DynamicDir
      BaseJob.prepend Tenants::BaseJob
      ApplicationMailer.include Tenants::DynamicUrlHost
      MailRelay::Lists.prepend Tenants::MailRelay::Lists
      MailingLists::BulkMail::Retriever.prepend Tenants::MailingLists::BulkMail::Retriever

      Ability.prepend Tenants::Ability
      Ability.store.register TenantAbility

      admin = NavigationHelper::MAIN.find { |opts| opts[:label] == :admin }
      admin[:active_for] << 'tenants'
    end

    initializer 'tenants.configure_apartment' do |_app|
      require 'apartment/elevators/main_subdomain'
      require 'hitobito_tenants/apartment'

      Rails.application.config.middleware.insert_before Rack::Cors,
                                                        Apartment::Elevators::MainSubdomain
    end

    initializer 'tenants.add_settings' do |_app|
      Settings.add_source!(File.join(paths['config'].existent, 'settings.yml'))
      Settings.reload!
    end

    initializer 'tenants.tenant_specific_config', before: :add_to_prepare_blocks do |app|
      app.config.cache_store = :dalli_store,
                               { compress: true,
                                 namespace: -> { Apartment::Tenant.current } }

      app.config.to_prepare do
        mailer_sender = ->(_mailer) { "hitobito <noreply@#{Apartment.current_host_name}>" }
        ActionMailer::Base.default(from: mailer_sender)
        Devise.mailer_sender = mailer_sender
      end
    end

    def seed_fixtures
      fixtures = root.join('db', 'seeds')
      ENV['NO_ENV'] ? [fixtures] : [fixtures, File.join(fixtures, Rails.env)]
    end

  end
end
