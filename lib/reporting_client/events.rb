# frozen_string_literal: true

require 'active_support'
require 'rubygems'

module ReportingClient
  class Events
    cattr_accessor :events, default: []

    attr_reader :event_name, :heap_identity, :land

    def self.instrumentable_name(event_name)
      event_name.to_s.gsub('_event', '').camelcase
    end

    def self.register(event_name)
      events = []
      unless events.include?(event_name)
        events << event_name

        subscribe(instrumentable_name(event_name))
      end
    end

    def self.subscribe(event_name)
      ActiveSupport::Notifications.subscribe(event_name) do |name, _start, _finish, _id, payload|
        if defined?(Current) && Current.attributes.present?
          Current.attributes.each do |title, attribute|
            payload[title] = attribute if attribute.present?
          end
        end

        ::NewRelic::Agent.record_custom_event(name.to_s, payload)
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

    def send_event(data)
      data.merge! Current.attributes if defined?(Current) && Current.attributes.present?

      ActiveSupport::Notifications.instrument(ReportingClient::Events.instrumentable_name(event_name), data)

      land.queue_event(ReportingClient::Events.instrumentable_name(event_name), data) if land.present?

      if heap_identity.present?
        ReportingClient::Heap.call(identity: heap_identity, event_name: ReportingClient::Events.instrumentable_name(event_name),
                                   properties: data)
      end
    end
  end
end
