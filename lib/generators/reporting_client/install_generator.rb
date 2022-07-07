# frozen_string_literal: true

require 'rails/generators'

module ReportingClient
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      class_option :skip_current_controller_concern,
                   type: :boolean,
                   desc: 'Do not create app/controllers/reporting_client/set_current.rb',
                   default: false
      class_option :skip_initializer,
                   type: :boolean,
                   desc: 'Do not create config/initializer/reporting_client.rb',
                   default: false

      desc 'Add controller concern template to application hooked into application controller.'
      def add_controller_concern
        return if options[:skip_current_controller_concern]

        insert_into_file 'app/controllers/application_controller.rb', "  include ReportingClient::SetCurrent\n", after: /class ApplicationController.*\n/
        template 'controllers/concerns/set_current.rb', 'app/controllers/concerns/reporting_client/set_current.rb'
      end

      desc 'Copies initializer template to application.'
      def copy_initializer
        return if options[:skip_initializer]

        template 'initializer.rb', 'config/initializers/reporting_client.rb'
      end
    end
  end
end
