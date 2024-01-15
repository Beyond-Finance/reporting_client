# frozen_string_literal: true

require 'active_job'
require_relative './heap'

module ReportingClient
  class HeapJob < ActiveJob::Base
    def perform(event_name, identity, properties, timestamp=Time.now.iso8601)
      Heap.new(event_name:, identity:, properties:, timestamp:).track
    end
  end
end
