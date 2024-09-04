# frozen_string_literal: true

require 'active_support'
require 'request_store'

module ReportingClient
  class Current < ActiveSupport::CurrentAttributes
    class << self
      # extend ActiveSupport::CurrentAttributes attribute with adding to NewRelic::Agent
      def attribute(*names)
        super(*names)

        names&.each do |name|
          define_method("#{name}=") do |value|
            super(value)
            ::NewRelic::Agent.add_custom_attributes(name => value)
          end
        end
      end

      # execute super class :attribute with adding to NewRelic::Agent and RequestStore
      def attribute_with_request_store(*names)
        method(:attribute).super_method.call(*names)

        names&.each do |name|
          define_method("#{name}=") do |value|
            super(value)
            RequestStore[name] = value
            ::NewRelic::Agent.add_custom_attributes(name => value)
          end
        end
      end
    end

    def assign_attributes(new_attributes)
      new_attributes.each { |key, value| public_send("#{key}=", value) }
    end
  end
end
