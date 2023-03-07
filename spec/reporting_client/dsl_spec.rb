# frozen_string_literal: true

require 'spec_helper'

class Foo
  include ReportingClient::DSL

  attr_accessor :bat

  def initialize
    @bat = :value_a
  end

  def error_method
    report_uncaught_errors(event: event, meta: meta)
  end

  def method_a
    report_uncaught_errors(event: event, meta: meta) do
      return :success
    end
  end

  def method_b
    meta = { bat: @bat }

    report_uncaught_errors(event: event, meta: meta) do
      raise StandardError, 'Oops'
    end
  end

  def method_c
    report_uncaught_errors(event: event, meta: :meta) do
      raise StandardError, 'Oops'
    end
  end

  def method_d
    report_uncaught_errors(event: event, meta: { bat: @bat }) do
      @bat = :value_b
      raise StandardError, 'Delayed oops'
    end
  end

  def method_e
    meta = { bat: @bat }

    report_uncaught_errors(event: event, meta: meta) do
      meta[:bat] = :value_b
      raise StandardError, 'Delayed oops'
    end
  end

  def method_f
    report_uncaught_errors(event: event, meta: :meta) do
      @bat = :value_b
      raise StandardError, 'Delayed oops'
    end
  end

  private

  def meta
    { bat: @bat }
  end

  def event
    @event ||= ReportingClient::Event.new
  end
end

RSpec.describe ReportingClient::DSL do
  # Usually testing private methods is bad, but since this private method is being
  # exported to other applications for use internally in classes for reporting,
  # it's probably best to have a regression test for it in the gem.
  describe '#report_uncaught_errors' do
    context 'when no error is raised' do
      context 'when no block is given' do
        it 'raieses LocalJumpError' do
          expect { Foo.new.error_method }.to raise_error(LocalJumpError)
        end
      end

      context 'when a block is given' do
        it 'returns the block value' do
          expect(Foo.new.method_a).to eq :success
        end
      end
    end

    context 'when an error is raised' do
      let(:event) { instance_double(ReportingClient::Event) }
      let(:instrument_hash) { { success: false, fail_reason: fail_reason, meta: meta } }
      let(:fail_reason) { 'Oops' }
      let(:meta) { { bat: :value_a } }

      before do
        allow(ReportingClient::Event).to receive(:new).and_return(event)
        allow(event).to receive(:instrument).and_return(true)
      end

      context 'when the meta is a variable' do
        it 'instruments with the meta' do
          expect { Foo.new.method_b }.to raise_error(StandardError)

          expect(event).to have_received(:instrument).with(instrument_hash)
        end
      end

      context 'when the meta is a symbol' do
        it 'instruments the meta by sending the symbol' do
          expect { Foo.new.method_c }.to raise_error(StandardError)

          expect(event).to have_received(:instrument).with(instrument_hash)
        end
      end

      context 'when the meta value has be modified in the block' do
        let(:fail_reason) { 'Delayed oops' }

        context 'when the meta is instantiated in the method signature' do
          let(:meta) { { bat: :value_a } }

          it "doesn't update the value" do
            expect { Foo.new.method_d }.to raise_error(StandardError)

            expect(event).to have_received(:instrument).with(instrument_hash)
          end
        end

        context 'when the meta is a variable' do
          let(:meta) { { bat: :value_b } }

          it 'does update the value' do
            expect { Foo.new.method_e }.to raise_error(StandardError)

            expect(event).to have_received(:instrument).with(instrument_hash)
          end
        end

        context 'when the meta is a symbol' do
          let(:meta) { { bat: :value_b } }

          it 'does update the value' do
            expect { Foo.new.method_f }.to raise_error(StandardError)

            expect(event).to have_received(:instrument).with(instrument_hash)
          end
        end
      end
    end
  end
end
