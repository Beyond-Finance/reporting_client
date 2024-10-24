# frozen_string_literal: true

require 'simplecov'
require 'simplecov-cobertura'

SimpleCov.start 'rails' do
  add_filter '/spec'
  add_filter '/lib/reporting_client/version'
  add_filter '/lib/generators'

  formatter SimpleCov::Formatter::CoberturaFormatter
end

require 'bundler/setup'
require 'securerandom'
require 'reporting_client'
require 'pry'
require 'faker'
require 'webmock/rspec'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.mock_with :rspec do |mocks|
    mocks.allow_message_expectations_on_nil = true
  end

  WebMock.disable_net_connect!
end
