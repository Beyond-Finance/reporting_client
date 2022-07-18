# frozen_string_literal: true

require 'active_support'
require 'rubygems'

require_relative 'events'

module ReportingClient
  class Event < Events
    private

    def instrumentable_name
      @instrumentable_name ||= ReportingClient.configuration.instrumentable_name
    end
  end
end
