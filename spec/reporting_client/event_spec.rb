# frozen_string_literal: true

require 'spec_helper'
require 'active_support'
require 'rubygems'
require 'active_support/core_ext'

RSpec.describe ReportingClient::Event do
  before { stub_const('::NewRelic::Agent', double(add_custom_attributes: nil, record_custom_event: nil)) }

  describe '#instrument' do
    let(:config) { ReportingClient.configuration }
    let(:data) { { success: true } }
    let(:event) { described_class.new(heap_identity: identity, land: land) }
    let(:instrumentable_name) { :test_event }
    let(:heap_app_id) { '123' }
    let(:identity) { Faker::Base.numerify('####') }
    let(:land) { double('land') }
    let(:url) { 'https://heapanalytics.com/api/track' }
    before do
      allow(config).to receive(:heap_app_id).and_return(heap_app_id)
      allow(config).to receive(:instrumentable_name).and_return(instrumentable_name)
      allow(land).to receive(:queue_event).and_return(nil)
      allow(ReportingClient::Heap).to receive(:call).and_return('OK')
      allow(ActiveSupport::Notifications).to receive(:instrument).and_call_original
    end

    context 'when no attributes defined on Current' do
      before { event.instrument(data) }

      it 'sends events to heap, new relic, and land' do
        expect(ActiveSupport::Notifications).to have_received(:instrument).with(instrumentable_name, a_hash_including(success: true))
        expect(ReportingClient::Heap).to have_received(:call).with(event_name: instrumentable_name, identity: identity, properties: a_hash_including(success: true))
        expect(land).to have_received(:queue_event).with(instrumentable_name, a_hash_including(success: true))
      end
    end

    context 'when attributes on Current defined and populated' do
      let(:id) { '1234' }
      before do
        ReportingClient::Current.attribute :id
        ReportingClient::Current.id = id
        event.instrument(data)
      end

      it 'sends events to heap, land, and new relic' do
        expect(ActiveSupport::Notifications).to have_received(:instrument).with(instrumentable_name, a_hash_including(success: true, id: id))
        expect(ReportingClient::Heap).to have_received(:call).with(event_name: instrumentable_name, identity: identity, properties: a_hash_including(success: true, id: id))
        expect(land).to have_received(:queue_event).with(instrumentable_name, a_hash_including(success: true, id: id))
      end

      context 'when land is not present' do
        let(:land) { nil }

        it 'sends events to heap and new relic' do
          expect(ActiveSupport::Notifications).to have_received(:instrument).with(instrumentable_name, a_hash_including(success: true, id: id))
          expect(ReportingClient::Heap).to have_received(:call).with(event_name: instrumentable_name, identity: identity, properties: a_hash_including(success: true, id: id))
          expect(land).to_not have_received(:queue_event)
        end
      end

      context 'when heap identity is not present' do
        let(:identity) { nil }

        it 'sends events to land and  new relic' do
          expect(ActiveSupport::Notifications).to have_received(:instrument).with(instrumentable_name, a_hash_including(success: true, id: '1234'))
          expect(land).to have_received(:queue_event).with(instrumentable_name, a_hash_including(success: true, id: '1234'))
          expect(ReportingClient::Heap).to_not have_received(:call)
        end
      end
    end
  end
end
