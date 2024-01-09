# frozen_string_literal: true

class ExceptionSerializer < ActiveJob::Serializers::ObjectSerializer
  def serialize?(argument)
    argument.is_a?(StandardError)
  end

  def serialize(exception)
    {
      'class' => exception.class.name,
      'message' => exception.message,
      'detailed_message' => exception.respond_to?(:detailed_message) ? exception.detailed_message : nil,
      'full_message' => exception.respond_to?(:full_message) ? exception.full_message : nil,
      'backtrace_locations' => exception.respond_to?(:backtrace_locations) ? exception.backtrace_locations : nil,
      'backtrace' => exception.backtrace,
      'cause' => exception.cause,
      'exception' => exception.respond_to?(:exception) ? exception.exception : nil
    }.compact_blank
  end

  def deserialize(hash)
    error = hash['class'].constantize.new(hash['message'])
    error.instance_variable_set(:@detailed_message, hash['detailed_message'])
    error.instance_variable_set(:@full_message, hash['full_message'])
    error.instance_variable_set(:@backtrace_locations, hash['backtrace_locations'])
    error.instance_variable_set(:@backtrace, hash['backtrace'])
    error.instance_variable_set(:@cause, hash['cause'])
    error.instance_variable_set(:@exception, hash['exception'])
    error
  end
end
