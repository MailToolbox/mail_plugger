# frozen_string_literal: true

module MailPlugger
  class Error < StandardError
    # Specific error class for errors if the client is not given or has the
    # wrong type.
    class WrongApiClient < Error; end

    # Specific error class for errors if it tries to add an undeclared option
    # in the configure block.
    class WrongConfigureOption < Error; end

    # Specific error class for errors if the default delivery options have the
    # wrong type.
    class WrongDefaultDeliveryOptions < Error; end

    # Specific error class for errors if the delivery options are not given or
    # have the wrong type.
    class WrongDeliveryOptions < Error; end

    # Specific error class for errors if the delivery settings have the wrong
    # type.
    class WrongDeliverySettings < Error; end

    # Specific error class for errors if the delivery system is not given.
    class WrongDeliverySystem < Error; end

    # Specific error class for errors if a parameter is not given.
    class WrongParameter < Error; end

    # Specific error class for errors if it tries to add an undeclared option
    # in the plug_in block.
    class WrongPlugInOption < Error; end
  end
end
