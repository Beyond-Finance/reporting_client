# frozen_string_literal: true

require 'active_support'
require 'rubygems'
require 'csv'

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

      def register_events_from_registry_csv
        raise ReportingClient::Exceptions::MissingRegistryCsvPath if ReportingClient.configuration.registry_csv_path.blank?

        documented_custom_events = CSV.read(ReportingClient.configuration.registry_csv_path, headers: true)
        documented_custom_events.each do |event|
          register(event['event_name'])
        end
      end

      def subscribe(event_name)
        ActiveSupport::Notifications.subscribe(event_name) do |name, _start, _finish, _id, payload|
          payload.merge!(Current.attributes.compact) if defined?(Current) && Current.attributes.present?

          name = "#{config.instrumentable_name}_#{name}" if config.prefix_new_relic_names
          ::NewRelic::Agent.record_custom_event(name.to_s, payload)
        end
      end

      private

      def config
        @config ||= ReportingClient.configuration
      end
    end

    def initialize(event_name:, heap_identity: nil, land: nil)
      raise ReportingClient::Exceptions::UnregisteredEventError, event_name if raises_unsupported && !events.include?(event_name)

      super(heap_identity: heap_identity, land: land)
      @event_name = event_name
    end

    private

    def instrumentable_name
      @instrumentable_name ||= self.class.instrumentable_name(event_name)
    end

    def raises_unsupported
      @raises_unsupported ||= ReportingClient.configuration.raises_on_unsupported_event
    end
  end
end
