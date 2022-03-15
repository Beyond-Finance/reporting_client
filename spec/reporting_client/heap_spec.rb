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
          'Content-Type' => 'application/json',
          'User-Agent' => 'Faraday v1.10.0'
        }
      ).to_return(status: 200, body: '', headers: {})
  end

  it 'makes an http call' do
    subject
    expect(a_request(:post, url)).to have_been_made
  end
end