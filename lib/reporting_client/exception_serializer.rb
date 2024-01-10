# frozen_string_literal: true

module ReportingClient
  class ExceptionSerializer < ActiveJob::Serializers::ObjectSerializer
    def serialize?(argument)
      argument.is_a?(StandardError)
    end

    def serialize(exception)
      {
        JSON.create_id => exception.class.name,
        'm' => exception.message,
        'b' => exception.backtrace
      }
    end

    def deserialize(hash)
      result = hash['json_class'].constantize.new(hash['m'])
      result.set_backtrace hash['b']
      result
    end
  end
end
