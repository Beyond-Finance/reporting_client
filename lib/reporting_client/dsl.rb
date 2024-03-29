# frozen_string_literal: true

module ReportingClient
  module DSL
    private

    def report_uncaught_errors(event:, meta:)
      yield
    rescue StandardError => e
      meta = send(meta) if meta.is_a? Symbol
      event.instrument(success: false, fail_reason: e.message, meta: meta)

      raise e
    end
  end
end
