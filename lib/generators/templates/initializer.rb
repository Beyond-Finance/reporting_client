# frozen_string_literal: true

ReportingClient.configure do |config|
  # reporting_client_config = Rails.application.config_for(:reporting_client)

  # config.environment = Rails.env
  # config.heap_app_id = reporting_client_config.heap_app_id
  # config.request_logger = 'RequestLogger::FaradayLogger'
  # config.timeout = reporting_client_config.timeout
end

# ReportingClient::Current.attribute :attr1, :attr2, ...
# ReportingClient::Current.attribute_with_request_store :attr3, :attr4, ...

# ActiveSupport::Notifications.subscribe(event_name) do |name, _start, _finish, _id, payload|
#   payload.merge!(Current.attributes.compact) if defined?(Current) && Current.attributes.present?

#   ::NewRelic::Agent.record_custom_event(name.to_s, payload)
# end