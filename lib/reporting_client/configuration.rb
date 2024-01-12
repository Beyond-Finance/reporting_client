# frozen_string_literal: true

module ReportingClient
  class Configuration
    attr_accessor :environment, :heap_app_id, :instrumentable_name, :timeout, :request_logger,
                  :prefix_new_relic_names, :raises_on_unsupported_event, :registry_csv_path,
                  :heap_async

    def initialize
      @environment = nil
      @heap_app_id = nil
      @instrumentable_name = nil
      @request_logger = 'NoopLogger'
      @timeout = nil
      @prefix_new_relic_names = false
      @raises_on_unsupported_event = false
      @registry_csv_path = nil
      @heap_async = false
    end
  end
end
