# frozen_string_literal: true

module ReportingClient
  class Configuration
    attr_accessor :environment, :heap_app_id, :instrumentable_name, :timeout, :request_logger

    def initialize
      @environment = nil
      @heap_app_id = nil
      @instrumentable_name = nil
      @request_logger = 'NoopLogger'
      @timeout = nil
    end
  end
end
