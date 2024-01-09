# frozen_string_literal: true

require 'active_job'
require_relative './heap'

module ReportingClient
  class HeapJob < ActiveJob::Base
    def perform(event_name, identity, properties)
      Heap.new(event_name: event_name, identity: identity, properties: properties).track
    end
  end
end
