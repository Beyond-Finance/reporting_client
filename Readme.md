# Reporting Client
 Contains a framework for sending custom events to APM tools

## Installing

Add the following line to your Gemfile:

```ruby
gem 'reporting_client'
```

And then execute:
  $ bundle install

Or, install it yourself:
    $ gem install reporting_client

Install the gem's initializer template to `config/initializers/reporting_client.rb` by running
  $ bin/rails g reporting_client:install

### Configure ReportingClient::Current

Reporting client implements a subclass of [ActiveSupport::CurrentAttributes](https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) for consumers to use, with `NewRelic` and, optionally, `RequestStore` tracking.

Within the initializer, provide a list of symbols to `ReportingClient::Current.attribute` for attributes you intend to populate and track to `NewRelic`, which will automatically be included in the event reporting.

Provide another list of symbols to `ReportingClient::Current.attribute_with_request_store` for attributes you with to send to both `NewRelic` and put in `RequestStore`.

The installer will also create a controller concern and include it in the `ApplicationController` for your application; each consumer needs to populate the values for the configured keys in this concern.

## Usage

# Multiple Event Names

Sends custom events to Heap, New Relic, and Land (a clickstream tracker for Rails applications).

```ruby
    ReportingClient::Events.register(<event_name>)
    event = ReportingClient::Events.new(event_name: <event_name-required>, heap_identity: <heap_identity-optional>, land: @land-optional )
    event.instrument(<event_name-required>, { success: <boolean-required>, fail_reason: <string-optional>, meta: <additional attributes-optional> })
```

Naming Events: New Relic requires event names to be camelcase so the gem will automatically change any event name to a string that is camelcase. For consistenty, this naming convention is carried over for all events no matter the APM tool.

Heap: A heap app id is required to be set up through configuration. Identity is also required to send a server side heap event. If heap is not applicable for your application, do not send an identity and no heap events will be sent.

Land: If a land event is not application to your application do not include the class instance and events will not be send to land.

# Single Event Name

In your applications intializer, set the desired event name for your application in `instrumentable_name`. To send a custom event use:

```ruby
    event = ReportingClient::Event.new(heap_identity: <heap_identity-optional>, land: @land-optional )
    event.instrument(success: <boolean-required>, fail_reason: <string-optional>, meta: <additional attributes-optional>)
```

Within the initializer, the following code is needed:

```ruby
  ActiveSupport::Notifications.subscribe(ReportingClient.configuration.instrumentable_name) do |name, _start, _finish, _id, payload|
     payload.merge!(Current.attributes.compact) if defined?(Current) && Current.attributes.present?

    ::NewRelic::Agent.record_custom_event(name.to_s, payload)
  end
```

# DSL Methods
`reporting_client` comes with a DSL mix-in that can be included in classes to add methods that help reduce boilerplate and increase abstraction around common operations. In order to include this mixin in your class, add teh following line to it.
```ruby
include ReportingClient::DSL
```
By including the DSL module, you gain access to the following methods:

**`report_uncaught_errors(event:, meta:)`:**

`report_uncaught_errors` removes the need for common boilerplate around error decoration. A common requirement as part of setting up New Relic custom event dashboards is to dispatch failure events whenever an operation fails due to an error occuring. This results in ugly boilerplate that introduces unecessary risk for a non-business logic operation. This method removes the need for that boilerplate.

For any section in which you'd like to dispatch a custom event indicating failure if an error occurs, use the following code block:
```ruby
report_uncaught_errors(event: event, meta: meta) do
  # The code that you'd like to dispatch events on error for.
end
```
`event`, in this circumstance is an instance of `Event` or `Events` which you'd like to use to call `instrument` on. `meta` can take one of two forms. First, it could be a `Symbol` that is the name of a method that you'd like to call in your object. That method should produce a `Hash` or some object that is compatible with being an argument for `merge` called on a `Hash`. Alternatively, `meta` could simply be an object compatible with being an argument for `merge` called on a `Hash`.

## Attribute Tracking
For per-request tracking of dimensions, set the attribute hash for the `ReportingClient::Current` object in the `app/controllers/concerns/reporting_client/set_current.rb` concern created by the installer. Each key in the hash must be included in the initializer for the gem as described above. For any key populated, value will be pushed to reporting endpoints automatically when making use of the `ReportingClient::Events` module.

## Server-side Heap Events
Tracking web custom events server side.

```ruby
ReportingClient::Heap.call(identity: heap_identity, event_name: event_name, properties: data)

```
