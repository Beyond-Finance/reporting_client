# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReportingClient::UnregisteredEventError do
  let(:event_name) { 'TestEvent' }

  describe '#message' do
    context 'when no message is passed in initialization' do
      subject { described_class.new(event_name) }

      it 'defaults to an appropriate error message' do
        expect(subject.message).to eq described_class::ERROR_MESSAGE
      end
    end

    context 'when a message is passed in initialization' do
      subject { described_class.new(event_name, message) }

      let(:message) { 'Test message' }

      it 'defaults to an appropriate error message' do
        expect(subject.message).to eq message
      end
    end
  end

  describe '#event_name' do
    subject { described_class.new(event_name) }

    it 'returns the value of the first positional argument' do
      expect(subject.event_name).to eq event_name
    end
  end
end
