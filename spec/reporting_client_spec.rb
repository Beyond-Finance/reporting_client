# frozen_string_literal: true

RSpec.describe ReportingClient do
  describe '.configuration' do
    it 'creates a new instance of Configuration' do
      expect(ReportingClient::Configuration).to receive(:new)
      described_class.reset
      described_class.configuration
    end
  end

  describe '.reset' do
    it 'creates and assigns a new instance of Configuration' do
      configuration = described_class.configuration
      expect(described_class.reset).not_to eq configuration
    end
  end

  describe '.configure' do
    let(:configuration_params) do
      { heap_app_id: '123',
        timeout: 1,
        environment: 'production',
        request_logger: 'noop_logger' }
    end

    it 'creates a new instance of Configuration from block' do
      described_class.configure do |config|
        config.heap_app_id = configuration_params[:heap_app_id]
        config.timeout = configuration_params[:timeout]
        config.environment = configuration_params[:environment]
        config.request_logger = configuration_params[:request_logger]
      end

      expect(ReportingClient.configuration).not_to be_nil
    end
  end
end
