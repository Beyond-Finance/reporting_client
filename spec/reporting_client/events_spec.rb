# frozen_string_literal: true

require 'spec_helper'
require 'active_support'
require 'rubygems'
require 'active_support/core_ext'

RSpec.describe ReportingClient::Events do
  let(:config) { ReportingClient.configuration }
  let(:subject) { described_class.new(heap_identity: identity, event_name: event_name, land: land) }
  let(:instrument) { subject.instrument(data) }
  let(:data) { { success: true } }
  let(:identity) { Faker::Base.numerify('####') }
  let(:event_name) { :test_event }
  let(:heap_app_id) { '123' }
  let(:url) { 'https://heapanalytics.com/api/track' }
  let(:land) { double('land') }

  before do
    stub_const('::NewRelic::Agent', double(record_custom_event: nil))
    allow(config).to receive(:heap_app_id).and_return(heap_app_id)
    ReportingClient::Events.register(event_name)
    allow(ReportingClient::Heap).to receive(:call).and_return('OK')
    allow(ActiveSupport::Notifications).to receive(:instrument).and_call_original
    allow(land).to receive(:queue_event).and_return(nil)
  end

  context 'when Current not defined' do
    it 'sends events to heap, new relic, and land' do
      instrument
      expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', { success: true })
      expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: { success: true })
      expect(land).to have_received(:queue_event).with('Test', { success: true })
    end
  end

  context 'when Current defined' do
    before { stub_const('Current', double(attributes: { id: '1234' })) }

    it 'sends events to heap, land, and new relic' do
      instrument
      expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', { success: true, id: '1234' })
      expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: { success: true, id: '1234' })
      expect(land).to have_received(:queue_event).with('Test', { success: true, id: '1234' })
    end

    context 'when land is not present' do
      let(:land) { nil }

      it 'sends events to heap and new relic' do
        instrument
        expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', { success: true, id: '1234' })
        expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: { success: true, id: '1234' })
        expect(land).to_not have_received(:queue_event)
      end
    end

    context 'when heap identity is not present' do
      let(:identity) { nil }

      it 'sends events to land and  new relic' do
        instrument
        expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', { success: true, id: '1234' })
        expect(land).to have_received(:queue_event).with('Test', { success: true, id: '1234' })
        expect(ReportingClient::Heap).to_not have_received(:call)
      end
    end
  end
end