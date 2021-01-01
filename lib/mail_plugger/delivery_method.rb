# frozen_string_literal: true

module MailPlugger
  class DeliveryMethod
    include MailHelper

    # Initialize delivery method attributes. If we are using MailPlugger.plug_in
    # method, then these attributes can be nil, if not then we should set these
    # attributes.
    #
    # @param [Hash] options with the credentials
    def initialize(options = {})
      @delivery_options        = options[:delivery_options] ||
                                 MailPlugger.delivery_options

      @client                  = options[:client] || MailPlugger.client

      @default_delivery_system = options[:default_delivery_system] ||
                                 default_delivery_system_get

      @delivery_settings       = options[:delivery_settings] ||
                                 MailPlugger.delivery_settings

      @message                 = nil
    end

    # Send message with the given client if the message parameter is a
    # Mail::Message object. Before doing that extract those information from the
    # Mail::Message object which was provided in the 'delivery_options'. After
    # that it generates a hash with these data and sends the message with the
    # provided client class which has a 'deliver' method.
    #
    # @param [Mail::Message] message what we would like to send
    def deliver!(message)
      unless message.is_a?(Mail::Message)
        raise Error::WrongParameter,
              'The given parameter is not a Mail::Message'
      end

      @message = message

      client.new(delivery_data).deliver
    end
  end
end
