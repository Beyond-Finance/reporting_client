# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReportingClient::Configuration do
  let(:configuration_params) do
    { timeout: 1,
      environment: 'test',
      request_logger: 'noop_logger',
      heap_app_id: '123' }
  end

  before do
    ReportingClient.configure do |config|
      config.heap_app_id = configuration_params[:heap_app_id]
      config.timeout = configuration_params[:timeout]
      config.environment = configuration_params[:environment]
      config.request_logger = configuration_params[:request_logger]
    end
  end

  describe '.new' do
    subject { ReportingClient.configuration }

    it 'includes api url' do
      expect(subject.heap_app_id).to eq(configuration_params[:heap_app_id])
    end

    it 'includes timeout' do
      expect(subject.timeout).to eq(configuration_params[:timeout])
    end

    it 'includes environment' do
      expect(subject.environment).to eq(configuration_params[:environment])
    end

    it 'includes request logger' do
      expect(subject.request_logger).to eq(configuration_params[:request_logger])
    end
  end
end
