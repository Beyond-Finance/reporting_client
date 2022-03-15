# frozen_string_literal: true

require 'reporting_client/configuration'
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