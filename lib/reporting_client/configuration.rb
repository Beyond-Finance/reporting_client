# frozen_string_literal: true

module ReportingClient
    class Configuration
      attr_accessor :environment, :heap_app_id, :timeout, :request_logger
  
      def initialize
        @heap_app_id = nil
        @timeout = nil
        @environment = nil
        @request_logger = 'NoopLogger'
      end
    end
  end