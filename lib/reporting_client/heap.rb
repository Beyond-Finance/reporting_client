# frozen_string_literal: true

require 'faraday'
require 'json'
require_relative 'noop_logger'

module ReportingClient
  class Heap
    attr_accessor :event_name, :properties, :identity

    HEAP_EVENT_TRACKING_URL = 'https://heapanalytics.com/api/track'

    def self.call(**args)
      new(**args).call
    end

    def initialize(event_name:, identity:, properties:)
      @event_name = event_name
      @identity = identity
      @properties = properties
    end

    def call
      response = conn.post do |req|
        req.body = body
        req.options[:timeout] = config.timeout
      end
      request_logger.log_response(response)
    rescue StandardError => e
      request_logger.log_error(e)
      raise
    end

    def conn
      @conn ||= Faraday.new(
        url: HEAP_EVENT_TRACKING_URL,
        headers: { content_type: 'application/json' }
      ) do |faraday|
        faraday.request :json
      end
      request_logger.log_request(HEAP_EVENT_TRACKING_URL, body, http_method: :post)

      @conn
    end

    def body
      { app_id: config.heap_app_id,
        identity: identity,
        event: event_name,
        timestamp: Time.now.iso8601,
        properties: properties.transform_keys(&:to_sym) }
    end

    def config
      @config ||= ReportingClient.configuration
    end

    def request_logger
      @request_logger ||= Object.const_get(config.request_logger).new
    end
  end
end
