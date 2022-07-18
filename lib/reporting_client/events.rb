# frozen_string_literal: true

require 'active_support'
require 'rubygems'

require_relative 'event'

module ReportingClient
  class Events < Event
    cattr_accessor :events, default: []

    attr_reader :event_name

    class << self
      def instrumentable_name(event_name)
        event_name.to_s.gsub('_event', '').camelcase
      end

      def register(event_name)
        return if events.include?(event_name)

        events << event_name
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
      super(heap_identity: heap_identity, land: land)
      @event_name = event_name
    end

    private

    def instrumentable_name
      @instrumentable_name ||= self.class.instrumentable_name(event_name)
    end
  end
end
