# frozen_string_literal: true

class NoopLogger
  attr_reader :raw_request

  def log_request(url, lead_request, headers); end

  def log_response(response); end

  def log_error(exception); end
end
