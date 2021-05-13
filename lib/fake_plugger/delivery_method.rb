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
    #   e.g. 'defined_api'
    #
    # @option options [Boolean] debug
    #   if true it will show debug informations
    #
    # @option options [Boolean] raw_message
    #   if true it will show raw message
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

      # Sepcial semaphore for the settings method that
      # FakePlugger::DeliveryMethod can behaves like MailPlugger::DeliveryMethod
      @initialize       = true

      @debug            = options[:debug] ||
                          settings[:fake_plugger_debug] || false

      @raw_message      = options[:raw_message] ||
                          settings[:fake_plugger_raw_message] || false

      @response         = options[:response] || settings[:fake_plugger_response]

      @use_mail_grabber = options[:use_mail_grabber] ||
                          settings[:fake_plugger_use_mail_grabber] || false

      @initialize       = false

      # Clear memoized values
      @delivery_system  = nil

      @settings         = nil
    end

    # Using SMTP:
    # Mock send message via SMTP protocol if the 'delivery_settings' contains a
    # 'smtp_settings' key and the value is a hash with the settings.
    #
    # Using API:
    # Mock send message with the given client if the message parameter is a
    # Mail::Message object. If 'response' parameter is nil then it will extract
    # those information from the Mail::Message object which was provided in the
    # 'delivery_options'. After that it generates a hash with these data and
    # returns with the provided client class which has a 'deliver' method, but
    # it won't call the 'deliver' method.
    # If the 'response' parameter is a hash with 'return_delivery_data: true'
    # then it will retrun with the extracted delivery data.
    #
    #
    # If the 'response' parameter is not nil then retruns with that given data
    # without call any other methods.
    # Except if 'debug' is true. In this case it will call those methods which
    # is calling in normal operation as well.
    # If 'debug' is true then it prints out some debug informations.
    # If 'raw_message' is true then it prints out raw message.
    # if 'use_mail_grabber' is true then it stores the message in a database.
    #
    # @param [Mail::Message] message what we would like to send
    #
    # @return [Mail::Message/Hash] depends on the given value
    #
    # @example
    #
    #   # Using SMTP:
    #
    #   MailPlugger.plug_in('test_api_client') do |smtp|
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
    #     api.delivery_options = %i[from to subject body]
    #     api.delivery_settings = {
    #       fake_plugger_debug: true,
    #       fake_plugger_raw_message: true,
    #       fake_plugger_use_mail_grabber: true,
    #       fake_plugger_response: { response: 'OK' }
    #     }
    #     api.client = DefinedApiClientClass
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
    #     delivery_options: %i[from to subject body],
    #     client: DefinedApiClientClass,
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

      call_extra_options

      return_with_response
    end

    private

    # Call extra options like show debug informations, show raw message,
    # use mail grabber.
    def call_extra_options
      show_debug_info if @debug
      show_raw_message if @raw_message

      return unless Gem.loaded_specs.key?('mail_grabber') && @use_mail_grabber

      MailGrabber::DeliveryMethod.new.deliver!(@message)
    end

    # Debug informations for API
    def debug_info_for_api
      puts <<~DEBUG_INFO

        ===================== FakePlugger::DeliveryMethod =====================

        ------------------------------ Variables ------------------------------

        ==> @client: #{@client.inspect}

        ==> @delivery_options: #{@delivery_options.inspect}

        ==> @delivery_settings: #{@delivery_settings.inspect}

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

    # Check that it should retrun with the delivery data.
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

    # Show debug informations from variables and methods.
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
  end
end
