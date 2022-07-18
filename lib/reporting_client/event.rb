# frozen_string_literal: true

require 'active_support'
require 'rubygems'

module ReportingClient
  class Event
    attr_reader :heap_identity, :land

    def initialize(heap_identity: nil, land: nil)
      @heap_identity = heap_identity
      @land = land
    end

    def instrument(success:, fail_reason: nil, meta: {})
      data = { success: success }
      data.merge!(fail_reason: fail_reason) if fail_reason.present?
      data.merge!(meta) if meta.present?
      send_event(data)
    end

    private

    def instrumentable_name
      @instrumentable_name ||= ReportingClient.configuration.instrumentable_name
    end

    def send_event(data)
      data.merge! Current.attributes if defined?(Current) && Current.attributes.present?

      ActiveSupport::Notifications.instrument(instrumentable_name, data)

      Heap.call(identity: heap_identity, event_name: instrumentable_name, properties: data) if heap_identity.present?
      land.queue_event(instrumentable_name, data) if land.present?
    end
  end
end
