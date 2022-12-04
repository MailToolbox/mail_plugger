# frozen_string_literal: true

require 'mail_grabber' if Gem.loaded_specs.key?('mail_grabber')

module FakePlugger
  class DeliveryMethod < MailPlugger::DeliveryMethod
    # Initialize FakePlugger delivery method attributes. If we are using
    # MailPlugger.plug_in method, then these attributes can be nil, if not then
    # we should set these attributes.
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
    #   e.g. 'api_client'
    #
    # @option options [Boolean] debug
    #   if true, it will show debug information
    #
    # @option options [Boolean] raw_message
    #   if true, it will show raw message
    #
    # @option options [String/Symbol/Array/Hash] response
    #   the deliver! method will return with this value or if this value is nil
    #   then it will return with the client object
    #
    # @option options [Boolean] use_mail_grabber
    #   if true it will store the message in a database which MailGrabber can
    #   read
    def initialize(options = {})
      super

      @debug            = options[:debug]

      @raw_message      = options[:raw_message]

      @response         = options[:response]

      @use_mail_grabber = options[:use_mail_grabber]
    end

    # Using SMTP:
    # Mock send message via SMTP protocol if the 'delivery_settings' contains a
    # 'smtp_settings' key and the value is a hash with the settings.
    #
    # Using API:
    # Mock send message with the given client if the message parameter is a
    # Mail::Message object. If 'response' parameter is nil, then it will extract
    # this information from the Mail::Message object which was provided in the
    # 'delivery_options'. After that it generates a hash with these data and
    # returns with the provided client class which has a 'deliver' method, but
    # it won't call the 'deliver' method.
    # If the 'response' parameter is a hash with 'return_delivery_data: true'
    # then it will return with the extracted delivery data.
    #
    #
    # If the 'response' parameter is not nil, then returns with that given data
    # without call any other methods.
    # Except if 'debug' is true. In this case, it will call those methods which
    # are calling in normal operation as well.
    # If 'debug' is true, then it prints out some debug information.
    # If 'raw_message' is true, then it prints out raw message.
    # If 'use_mail_grabber' is true, then it stores the message in a database.
    #
    # @param [Mail::Message] message what we would like to send
    #
    # @return [Mail::Message/Hash] depends on the given value
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
    #   FakePlugger::DeliveryMethod.new.deliver!(message)
    #
    #   # or
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   FakePlugger::DeliveryMethod.new(
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
    #     api.client = DefinedApiClientClass
    #     api.delivery_options = %i[from to subject body]
    #     api.delivery_settings = {
    #       fake_plugger_debug: true,
    #       fake_plugger_raw_message: true,
    #       fake_plugger_use_mail_grabber: true,
    #       fake_plugger_response: { response: 'OK' }
    #     }
    #   end
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   FakePlugger::DeliveryMethod.new.deliver!(message)
    #
    #   # or
    #
    #   message = Mail.new(from: 'from@example.com', to: 'to@example.com',
    #                      subject: 'Test email', body: 'Test email body')
    #
    #   FakePlugger::DeliveryMethod.new(
    #     client: DefinedApiClientClass,
    #     delivery_options: %i[from to subject body],
    #     debug: true,
    #     raw_message: true,
    #     use_mail_grabber: true,
    #     response: { response: 'OK' }
    #   ).deliver!(message)
    #
    def deliver!(message)
      unless message.is_a?(Mail::Message)
        raise MailPlugger::Error::WrongParameter,
              'The given parameter is not a Mail::Message'
      end

      @message = message

      update_settings

      call_extra_options

      return_with_response
    end

    private

    # Call extra options like show debug information, show raw message,
    # use mail grabber.
    def call_extra_options
      show_debug_info if @debug
      show_raw_message if @raw_message

      return unless Gem.loaded_specs.key?('mail_grabber') && @use_mail_grabber

      MailGrabber::DeliveryMethod.new.deliver!(@message)
    end

    # Debug information for API
    def debug_info_for_api # rubocop:disable Metrics/AbcSize
      puts <<~DEBUG_INFO

        ===================== FakePlugger::DeliveryMethod =====================

        ------------------------------ Variables ------------------------------

        ==> @client: #{@client.inspect}

        ==> @delivery_options: #{@delivery_options.inspect}

        ==> @delivery_settings: #{@delivery_settings.inspect}

        ==> @passed_delivery_system: #{@passed_delivery_system.inspect}

        ==> @default_delivery_options: #{@default_delivery_options.inspect}

        ==> @sending_method: #{@sending_method.inspect}

        ==> @default_delivery_system: #{@default_delivery_system.inspect}

        ==> @message: #{@message.inspect}

        ------------------------------- Methods -------------------------------

        ==> client: #{client.inspect}

        ==> delivery_system: #{delivery_system.inspect}

        ==> delivery_options: #{delivery_options.inspect}

        ==> delivery_data: #{delivery_data.inspect}

        ==> settings: #{settings.inspect}

        =======================================================================

      DEBUG_INFO
    end

    # Debug information for SMTP
    def debug_info_for_smtp
      puts <<~DEBUG_INFO

        ===================== FakePlugger::DeliveryMethod =====================

        ------------------------------ Variables ------------------------------

        ==> @delivery_settings: #{@delivery_settings.inspect}

        ==> @passed_delivery_system: #{@passed_delivery_system.inspect}

        ==> @sending_method: #{@sending_method.inspect}

        ==> @default_delivery_system: #{@default_delivery_system.inspect}

        ==> @message: #{@message.inspect}

        ------------------------------- Methods -------------------------------

        ==> delivery_system: #{delivery_system.inspect}

        ==> settings: #{settings.inspect}

        =======================================================================

      DEBUG_INFO
    end

    # Prepare delivery. It depends on that is SMTP or API.
    def prepare_delivery
      if send_via_smtp?
        @message.delivery_method :smtp, settings[:smtp_settings]
        @message
      else
        client.new(delivery_data)
      end
    end

    # Check that it should return with the delivery data.
    def return_delivery_data?
      !send_via_smtp? &&
        @response.is_a?(Hash) &&
        @response[:return_delivery_data]
    end

    # Return with a response which depends on the conditions.
    def return_with_response
      return prepare_delivery if @response.nil?

      return delivery_data if return_delivery_data?

      @response
    end

    # Show debug information from variables and methods.
    def show_debug_info
      send_via_smtp? ? debug_info_for_smtp : debug_info_for_api
    end

    # Show raw message for debug purpose.
    def show_raw_message
      puts <<~RAW_MESSAGE

        ============================ Mail::Message ============================

        #{@message}

        =======================================================================

      RAW_MESSAGE
    end

    # Extract settings values and update attributes.
    def update_settings
      @response = settings[:fake_plugger_response] if @response.nil?

      %w[debug raw_message use_mail_grabber].each do |variable_name|
        next unless instance_variable_get("@#{variable_name}").nil?

        instance_variable_set(
          "@#{variable_name}",
          settings[:"fake_plugger_#{variable_name}"] || false
        )
      end
    end
  end
end
