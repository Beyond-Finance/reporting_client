# frozen_string_literal: true

require 'rails/generators'

module ReportingClient
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __dir__)

      class_option :skip_initializer,
                   type: :boolean,
                   desc: 'Do not create config/initializer/reporting_client.rb',
                   default: false
      desc 'Copies initializer template to application.'
      def copy_initializer
        return if options[:skip_initializer]

        template 'reporting_client.rb', 'config/initializers/reporting_client.rb'
      end
    end
  end
end
