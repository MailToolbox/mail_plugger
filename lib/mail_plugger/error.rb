# frozen_string_literal: true

module MailPlugger
  class Error < StandardError
    # Specific error class for errors if tries to add undelclared option
    # in plug_in block
    class WrongPlugInOption < Error; end

    # Specific error class for errors if delivery system is not given
    class WrongDeliverySystem < Error; end

    # Specific error class for errors if delivery options is not given or
    # has a wrong type
    class WrongDeliveryOptions < Error; end

    # Specific error class for errors if client is not given or has a wrong type
    class WrongApiClient < Error; end

    # Specific error class for errors if parameter is not given
    class WrongParameter < Error; end
  end
end
