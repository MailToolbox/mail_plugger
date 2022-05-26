# frozen_string_literal: true

module MailPlugger
  class DeliveryMethod
    include MailHelper

    # Initialize delivery method attributes. If we are using MailPlugger.plug_in
    # method, then these attributes can be nil, if not then we should set these
    # attributes.
    #
    # @param [Hash] options check options below
    # @option options [Class/Hash] client
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

      @delivery_systems        = MailPlugger.delivery_systems

      @default_delivery_system = options[:default_delivery_system] ||
                                 default_delivery_system_get

      @message                 = nil
    end

    # Using SMTP:
    # Send message via SMTP protocol if the 'delivery_settings' contains a
    # 'smtp_settings' key and the value is a hash with the settings.
    #
    # Using API:
    # Send message with the given client if the message parameter is a
    # Mail::Message object. Before doing that, extract this information from the
    # Mail::Message object which was provided in the 'delivery_options'. After
    # that it generates a hash with these data and sends the message with the
    # provided client class which has a 'deliver' method.
    #
    # @param [Mail::Message] message what we would like to send
    #
    # @return [Mail::Message/Hash] depends on delivery_settings and method calls
    #
    # @example
    #
    #   # Using SMTP:
    #
    #   MailPlugger.plug_in('test_smtp_client') do |smtp|
    #     smtp.delivery_settings = {
    #       smtp_settings: {
    #         address: 'smtp.server.com',
    #         port: 587,
    #         domain: 'test.domain.com',
    #         enable_starttls_auto: true,
    #         user_name: 'test_user',
    #         password: '1234',
    #         authentication: :plain
    #       }
    #     }
    #   end
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   MailPlugger::DeliveryMethod.new.deliver!(message)
    #
    #   # or
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   MailPlugger::DeliveryMethod.new(
    #     delivery_settings: {
    #       smtp_settings: {
    #         address: 'smtp.server.com',
    #         port: 587,
    #         domain: 'test.domain.com',
    #         enable_starttls_auto: true,
    #         user_name: 'test_user',
    #         password: '1234',
    #         authentication: :plain
    #       }
    #     }
    #   ).deliver!(message)
    #
    #   # Using API:
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
    #   # or
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

      if send_via_smtp?
        message.delivery_method :smtp, settings[:smtp_settings]
        message.deliver!
      else
        client.new(delivery_data).deliver
      end
    end
  end
end
