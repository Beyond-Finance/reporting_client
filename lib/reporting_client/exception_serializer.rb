# frozen_string_literal: true
require "json/add/exception"

module ReportingClient
  class ExceptionSerializer < ActiveJob::Serializers::ObjectSerializer
    def serialize?(argument)
      argument.is_a?(StandardError)
    end

    def serialize(exception)
      exception.as_json
    end

    def deserialize(hash)
      hash['json_class'].constantize.json_create(hash)
    end
  end
end
