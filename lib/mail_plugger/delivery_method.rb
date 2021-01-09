# frozen_string_literal: true

module MailPlugger
  class DeliveryMethod
    include MailHelper

    # Initialize delivery method attributes. If we are using MailPlugger.plug_in
    # method, then these attributes can be nil, if not then we should set these
    # attributes.
    #
    # @param [Hash] options below
    # @option options [Class/Hash] :client
    #   e.g. DefinedApiClientClass or { 'key' => DefinedApiClientClass }
    #
    # @option options [Array/Hash] delivery_options
    #   e.g. [:to, :from, :subject, :body] or
    #   { 'key' => [:to, :from, :subject, :body] }
    #
    # @option options [Hash] delivery_settings
    #   e.g. { return_response: true }
    #
    # @option options [String/Symbol] default_delivery_system
    #   e.g. 'defined_api'
    def initialize(options = {})
      @client                  = options[:client] || MailPlugger.client

      @delivery_options        = options[:delivery_options] ||
                                 MailPlugger.delivery_options

      @delivery_settings       = options[:delivery_settings] ||
                                 MailPlugger.delivery_settings

      @default_delivery_system = options[:default_delivery_system] ||
                                 default_delivery_system_get

      @message                 = nil
    end

    # Send message with the given client if the message parameter is a
    # Mail::Message object. Before doing that extract those information from the
    # Mail::Message object which was provided in the 'delivery_options'. After
    # that it generates a hash with these data and sends the message with the
    # provided client class which has a 'deliver' method.
    #
    # @param [Mail::Message] message what we would like to send
    #
    # @return [Mail::Message/Hash] depend on delivery_settings and method calls
    #
    # @example
    #
    #   MailPlugger.plug_in('test_api_client') do |api|
    #     api.delivery_options = %i[from to subject body]
    #     api.client = DefinedApiClientClass
    #   end
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   MailPlugger::DeliveryMethod.new.deliver!(message)
    #
    # or
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   MailPlugger::DeliveryMethod.new(
    #     delivery_options: %i[from to subject body],
    #     client: DefinedApiClientClass
    #   ).deliver!(message)
    #
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
