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

    it 'defaults prefix_new_relic_names to false' do
      expect(subject.prefix_new_relic_names).to be false
    end

    it 'defaults raises_on_unsupported_event to false' do
      expect(subject.raises_on_unsupported_event).to be false
    end

    context 'a value is passed for prefix_new_relic_names' do
      before do
        ReportingClient.configure do |config|
          config.prefix_new_relic_names = true
        end
      end

      after do
        ReportingClient.configure do |config|
          config.prefix_new_relic_names = false
        end
      end

      it 'includes prefix_new_relic_names' do
        expect(subject.prefix_new_relic_names).to be true
      end
    end

    context 'a value is passed for raises_on_unsupported_event' do
      before do
        ReportingClient.configure do |config|
          config.raises_on_unsupported_event = true
        end
      end

      after do
        ReportingClient.configure do |config|
          config.raises_on_unsupported_event = true
        end
      end

      it 'includes raises_on_unsupported_event' do
        expect(subject.raises_on_unsupported_event).to be true
      end
    end
  end
end
