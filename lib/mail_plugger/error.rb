# frozen_string_literal: true

module MailPlugger
  class Error < StandardError
    # Specific error class for errors if client is not given or has a wrong
    # type.
    class WrongApiClient < Error; end

    # Specific error class for errors if tries to add undeclared option
    # in cofigure block.
    class WrongConfigureOption < Error; end

    # Specific error class for errors if default delivery opitons has a wrong
    # type.
    class WrongDefaultDeliveryOptions < Error; end

    # Specific error class for errors if delivery options are not given or
    # has a wrong type.
    class WrongDeliveryOptions < Error; end

    # Specific error class for errors if delivery settings has a wrong type.
    class WrongDeliverySettings < Error; end

    # Specific error class for errors if delivery system is not given.
    class WrongDeliverySystem < Error; end

    # Specific error class for errors if parameter is not given.
    class WrongParameter < Error; end

    # Specific error class for errors if tries to add undeclared option
    # in plug_in block.
    class WrongPlugInOption < Error; end
  end
end
