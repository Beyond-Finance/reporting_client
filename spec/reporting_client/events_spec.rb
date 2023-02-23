# frozen_string_literal: true

require 'spec_helper'
require 'active_support'
require 'rubygems'
require 'active_support/core_ext'

RSpec.describe ReportingClient::Events do
  before { stub_const('::NewRelic::Agent', double(add_custom_attributes: nil, record_custom_event: nil)) }

  describe 'initialize' do
    subject { described_class.new(event_name: event_name) }

    let(:event_name) { 'Event' }

    context 'when configured to raise on unsupported event creation' do
      before do
        ReportingClient.configuration.raises_on_unsupported_event = true
      end

      context 'if an unregistered is created' do
        it 'raises UnregisteredEventError' do
          expect { subject }.to raise_error(ReportingClient::UnregisteredEventError)
        end
      end

      context 'if a registered event is created' do
        before { described_class.register(event_name) }

        it "doesn't raise" do
          expect { subject }.not_to raise_error(ReportingClient::UnregisteredEventError)
        end
      end
    end

    context 'when configured to not raise on unsupported event creation' do
      it "doesn't raise even if the created event is unregistered" do
        expect { subject }.not_to raise_error(ReportingClient::UnregisteredEventError)
      end
    end
  end

  describe '.register' do
    let(:event1) { Faker::Lorem.unique.word.downcase }
    let(:event2) { Faker::Lorem.unique.word.downcase }
    let(:event3) { Faker::Lorem.unique.word.downcase }
    subject { described_class.events }

    before do
      described_class.events = []

      described_class.register event1
      described_class.register event2
      described_class.register event3
      described_class.register event2
      described_class.register event1
    end

    it 'adds each persistently uniquely and once' do
      is_expected.to contain_exactly event1, event2, event3
    end
  end

  describe '#instrument' do
    let(:config) { ReportingClient.configuration }
    let(:data) { { success: true } }
    let(:event) { described_class.new(heap_identity: identity, event_name: event_name, land: land) }
    let(:event_name) { :test_event }
    let(:heap_app_id) { '123' }
    let(:identity) { Faker::Base.numerify('####') }
    let(:land) { double('land') }
    let(:url) { 'https://heapanalytics.com/api/track' }
    before do
      allow(config).to receive(:heap_app_id).and_return(heap_app_id)
      allow(land).to receive(:queue_event).and_return(nil)
      allow(ReportingClient::Heap).to receive(:call).and_return('OK')
      allow(ActiveSupport::Notifications).to receive(:instrument).and_call_original
      ReportingClient::Events.register(event_name)
    end

    context 'when no attributes defined on Current' do
      before { event.instrument(success: true) }

      it 'sends events to heap, new relic, and land' do
        expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', a_hash_including(success: true))
        expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: a_hash_including(success: true))
        expect(land).to have_received(:queue_event).with('Test', a_hash_including(success: true))
      end
    end

    context 'when attributes on Current defined and populated' do
      let(:id) { '1234' }
      before do
        ReportingClient::Current.attribute :id
        ReportingClient::Current.id = id
        event.instrument(success: true)
      end

      it 'sends events to heap, land, and new relic' do
        expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', a_hash_including(success: true, id: id))
        expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: a_hash_including(success: true, id: id))
        expect(land).to have_received(:queue_event).with('Test', a_hash_including(success: true, id: id))
      end

      context 'when land is not present' do
        let(:land) { nil }

        it 'sends events to heap and new relic' do
          expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', a_hash_including(success: true, id: id))
          expect(ReportingClient::Heap).to have_received(:call).with(event_name: 'Test', identity: identity, properties: a_hash_including(success: true, id: id))
          expect(land).to_not have_received(:queue_event)
        end
      end

      context 'when heap identity is not present' do
        let(:identity) { nil }

        it 'sends events to land and  new relic' do
          expect(ActiveSupport::Notifications).to have_received(:instrument).with('Test', a_hash_including(success: true, id: '1234'))
          expect(land).to have_received(:queue_event).with('Test', a_hash_including(success: true, id: '1234'))
          expect(ReportingClient::Heap).to_not have_received(:call)
        end
      end
    end
  end
end
