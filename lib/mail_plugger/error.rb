module MailPlugger
  class Error < StandardError
    # Specific error class for errors if tries to add undelclared option
    # in plug_in block
    class WrongPlugInOption < Error; end

    # Specific error class for errors if delivery system is not given
    class WrongDeliverySystem < Error; end
  end
end
