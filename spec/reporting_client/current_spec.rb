# frozen_string_literal: true

require 'request_store'

RSpec.describe ReportingClient::Current do
  let(:key) { Faker::Lorem.word.downcase.to_sym }
  let(:new_relic) { double(add_custom_attributes: nil) }
  let(:val) { Faker::Lorem.word }
  before { stub_const('::NewRelic::Agent', new_relic) }
  subject { described_class.public_send key }

  describe '.attribute' do
    before do
      described_class.attribute key
      described_class.public_send "#{key}=", val
    end

    it 'sets registered attribute with New Relic' do
      is_expected.to eq val
      expect(new_relic).to have_received(:add_custom_attributes).with(key => val)
      expect(RequestStore[key]).to be_blank
    end
  end

  describe '.attribute_with_request_store' do
    before do
      described_class.attribute_with_request_store key
      described_class.public_send "#{key}=", val
    end

    it 'sets registered attribute with New Relic and RequestStore' do
      is_expected.to eq val
      expect(new_relic).to have_received(:add_custom_attributes).with(key => val)
      expect(RequestStore[key]).to eq val
    end
  end
end
