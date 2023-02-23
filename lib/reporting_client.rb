# frozen_string_literal: true

require 'reporting_client/configuration'
require 'reporting_client/current'
require 'reporting_client/errors'
require 'reporting_client/event'
require 'reporting_client/events'
require 'reporting_client/heap'
require 'reporting_client/version'

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
end
