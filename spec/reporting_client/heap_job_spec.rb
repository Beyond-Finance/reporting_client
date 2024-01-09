# frozen_string_literal: true

RSpec.describe ReportingClient::HeapJob do
  it 'calls Heap#track' do
    expect_any_instance_of(ReportingClient::Heap).to receive(:track)
    described_class.perform_now('event_name', 'identity', 'properties')
  end
end
