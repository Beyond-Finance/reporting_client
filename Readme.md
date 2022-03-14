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

## Usage

Sends custom events to Heap, New Relic, and Land (a clickstream tracker for Rails applications).

```ruby
    ReportingClient::Event.register(<event_name>)
    event = ReportingClient::Event.new(event_name: <event_name-required>, heap_identity: <heap_identity-optional>, land: @land-optional )
    event.send(<event_name-required>, { success: <boolean-required>, fail_reason: <string-optional>, meta: <additional attributes-optional> })
```

Naming Events: New Relic requires event names to be camelcase so the gem will automatically change any event name to a string that is camelcase. For consistenty, this naming convention is carried over for all events no matter the APM tool.

Heap: A heap app id is required to be set up through configuration. Identity is also required to send a server side heap event. If heap is not applicable for your application, do not send an identity and no heap events will be sent.

Land: If a land event is not application to your application do not include the class instance and events will not be send to land.

## Optional Attribute Tracking
Use ActiveSupport::CurrentAttributes for per-request tracking of dimensions. Refer to this [documentation]( https://api.rubyonrails.org/classes/ActiveSupport/CurrentAttributes.html) for help in setting up ActiveSupport::CurrentAttributes in your application.


## Server-side Heap Events
Tracking web custom events server side.

```ruby
ReportingClient::Heap.call(identity: heap_identity, event_name: event_name, properties: data)

```



