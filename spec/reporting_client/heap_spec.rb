# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReportingClient::Heap do
  let(:config) { ReportingClient.configuration }
  let(:subject) { described_class.call(identity: program_name, event_name: event_name, properties: properties) }
  let(:program_name) { Faker::Base.numerify('P-####') }
  let(:event_name) { 'Login' }
  let(:heap_app_id) { '123' }
  let(:url) { 'https://heapanalytics.com/api/track' }
  let(:properties) { { success: true } }
  let(:body) do
    { app_id: config.heap_app_id,
      identity: program_name,
      event: event_name,
      timestamp: Time.now.iso8601,
      properties: properties }
  end

  before do
    allow(config).to receive(:heap_app_id).and_return(heap_app_id)
    allow(config).to receive(:request_logger).and_return('NoopLogger')

    stub_request(:post, url)
      .with(
        body: body.to_json,
        headers: {
          'Accept' => '*/*',
          'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Content-Type' => 'application/json'
        }
      ).to_return(status: 200, body: '', headers: {})
  end

  it 'makes an http call' do
    subject
    expect(a_request(:post, url)).to have_been_made
  end

  context 'when an error occurs' do
    before do
      allow(Faraday).to receive(:new).and_raise(StandardError)
    end

    it 'raises an exception' do
      expect { subject }.to raise_error(StandardError)
    end
  end

  context 'with heap async set to true' do
    it 'enqueues a heap job' do
      allow(config).to receive(:heap_async).and_return(true)
      timestamp = Time.now
      expect(Time).to receive(:now).and_return(timestamp)

      expect(ReportingClient::HeapJob).to receive(:perform_later).with(event_name, program_name, properties, timestamp.iso8601)
      expect(Faraday).not_to receive(:new)
      subject
    end
  end

  context 'with heap async set to false' do
    it 'does not enqueue a heap job' do
      allow(config).to receive(:heap_async).and_return(false)

      expect(ReportingClient::HeapJob).not_to receive(:perform_later)
      expect(Faraday).to receive(:new).and_return(double(post: true))
      subject
    end
  end
end
