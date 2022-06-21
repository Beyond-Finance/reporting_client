# frozen_string_literal: true

module ReportingClient
  module SetCurrent
    extend ActiveSupport::Concern

    included { before_action :set_current }

    private

    # set the values for the Current attributes registered
    # in the initializer: config/initializers/reporting_client.rb
    # in order to set them on every controller action
    def set_current
      # ReportingClient::Current.assign_attributes(attr1: val1,
      #                                            attr2: val2,
      #                                            attr3: val3)
    end
  end
end
