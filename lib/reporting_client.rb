# frozen_string_literal: true

require 'reporting_client/configuration'
require 'reporting_client/current'
require 'reporting_client/exceptions'
require 'reporting_client/event'
require 'reporting_client/events'
require 'reporting_client/heap'
require 'reporting_client/dsl'
require 'reporting_client/version'
require 'reporting_client/heap_job'
require 'reporting_client/exception_serializer'

module ReportingClient
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.reset
    @configuration = nil
  end

  def self.configure
    yield configuration
  end

  def self.root
    Pathname.new(File.expand_path('..', __dir__))
  end
end
