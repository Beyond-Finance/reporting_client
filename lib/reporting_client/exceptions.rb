# frozen_string_literal: true

module ReportingClient
  module Exceptions
    class UnregisteredEventError < StandardError
      attr_reader :event_name

      ERROR_MESSAGE = <<~MESSAGE
        The event name that you've tried to instrument for has not been registered. Events
        must be registered prior to attempting to instrument them so that they are successfully
        dispatched to the appropriate services.

        In order to register an event type, call `ReportingClient::Events.register(your_event_name)`.
        This action is idemptotent, and it can be run multiple times for safety. You can disable
        this error by configuring `raises_on_unsupported_event` to be false.
      MESSAGE

      def initialize(event_name, message = ERROR_MESSAGE)
        @event_name = event_name
        super(message)
      end
    end
  end
end
