# frozen_string_literal: true

require 'active_support'
require 'rubygems'

module ReportingClient
  class Events
    cattr_accessor :events, default: []

    attr_reader :event_name, :heap_identity, :land

    class << self
      def instrumentable_name(event_name)
        event_name.to_s.gsub('_event', '').camelcase
      end

      def register(event_name)
        return if self.events.include?(event_name)

        self.events << event_name
        subscribe(instrumentable_name(event_name))
      end

      def subscribe(event_name)
        ActiveSupport::Notifications.subscribe(event_name) do |name, _start, _finish, _id, payload|
          payload.merge!(Current.attributes.compact) if defined?(Current) && Current.attributes.present?

          ::NewRelic::Agent.record_custom_event(name.to_s, payload)
        end
      end
    end

    def initialize(event_name:, heap_identity: nil, land: nil)
      @event_name = event_name
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
      @instrumentable_name ||= self.class.instrumentable_name(event_name)
    end

    def send_event(data)
      data.merge! Current.attributes if defined?(Current) && Current.attributes.present?

      ActiveSupport::Notifications.instrument(instrumentable_name, data)

      Heap.call(identity: heap_identity, event_name: instrumentable_name, properties: data) if heap_identity.present?
      land.queue_event(instrumentable_name, data) if land.present?
    end
  end
end
