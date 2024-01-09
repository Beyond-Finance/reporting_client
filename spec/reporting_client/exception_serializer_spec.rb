# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ExceptionSerializer do
  let(:error) { StandardError.new('test') }
  it 'serializes a StandardError' do
    expect(ExceptionSerializer.serialize(error)['message']).to eq('test')
  end

  it 'deserializes a StandardError' do
    serialized_error = ExceptionSerializer.serialize(error)
    expect(ExceptionSerializer.deserialize(serialized_error).message).to eq('test')
  end
end
