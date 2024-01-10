# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ReportingClient::ExceptionSerializer do
  let(:error) { StandardError.new('test') }
  it 'serializes a StandardError' do
    expect(ReportingClient::ExceptionSerializer.serialize(error)['m']).to eq('test')
  end

  it 'deserializes a StandardError' do
    serialized_error = ReportingClient::ExceptionSerializer.serialize(error)
    expect(ReportingClient::ExceptionSerializer.deserialize(serialized_error).message).to eq('test')
  end

  it 'validates that the argument is a StandardError' do
    expect(ReportingClient::ExceptionSerializer.serialize?(error)).to eq(true)
  end
end
