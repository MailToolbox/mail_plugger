# frozen_string_literal: true

require 'base64'

module MailPlugger
  module MailHelper
    # Check the version of a gem.
    #
    # @param [String] gem_name the name of the gem
    # @param [String] version the satisfied version of the gem
    #
    # @return [Boolean] true/false
    def check_version_of(gem_name, version)
      requirement     = Gem::Requirement.new(version)
      current_version = Gem.loaded_specs[gem_name].version

      requirement.satisfied_by?(current_version)
    end

    # Extract 'client'. If it's a hash then it'll return the right
    # client belongs to the delivery system. If it's not a hash it'll return
    # the given value. But if the value doesn't a class it'll raise an error.
    #
    # @return [Class] the defined API class
    def client
      api_client = option_value_from(@client)

      unless api_client.is_a?(Class)
        raise Error::WrongApiClient, '"client" does not a Class'
      end
      unless api_client.method_defined?(:deliver)
        raise Error::WrongApiClient, '"client" does not have "deliver" method'
      end

      api_client
    end

    # Collects data from Mail::Message object.
    #
    # @return [Hash] the data which was defined in 'delivery_options'
    def delivery_data
      data = {}

      delivery_options.each do |option|
        option = option.to_sym unless option.is_a?(Symbol)

        data[option] =
          case option
          when :from, :to, :cc, :bcc, :subject
            @message.public_send(option)
          when :attachments
            extract_attachments
          when :body, :html_part, :text_part
            @message.public_send(option)&.decoded
          when :message_obj
            @message
          else
            message_field_value_from(@message[option])
          end
      end

      data
    end

    # Tries to set up a default delivery system, if the 'delivery_system'
    # wasn't defined in the Mail::Message object and 'delivery_options' and/or
    # 'client' is a hash. Which means the MailPlugger.plugin method was used,
    # probably.
    #
    # @return [Stirng] the first key of the 'delivery_options' or 'client'
    def default_delivery_system_get
      if @delivery_options.is_a?(Hash)
        @delivery_options
      elsif @client.is_a?(Hash)
        @client
      end&.keys&.first
    end

    # Extract 'delivery_options'. If it's a hash then it'll return the right
    # options belongs to the delivery system. If it's not a hash it'll return
    # the given value. But if the value doesn't an array it'll raise an error.
    #
    # @return [Array] the options it'll collect from the Mail::Message object
    def delivery_options
      options = option_value_from(@delivery_options)

      unless options.is_a?(Array)
        raise Error::WrongDeliveryOptions,
              '"delivery_options" does not an Array'
      end

      options
    end

    # Extract 'delivery_system' from the Mail::Message object or if it's not
    # defined then use the default one. If it's still nil and one of the
    # 'delivery_options' or 'client' is a hash then raise error.
    #
    # @return [String] with the name of the delivery system
    def delivery_system
      @delivery_system ||=
        (@message && message_field_value_from(@message[:delivery_system])) ||
        @default_delivery_system

      if @delivery_system.nil? &&
         (@delivery_options.is_a?(Hash) || @client.is_a?(Hash))
        raise Error::WrongDeliverySystem,
              '"delivery_system" was not defined as a Mail::Message parameter'
      end

      @delivery_system
    end

    # Extract attachments.
    #
    # @return [Array] with extracted attachment hashes
    def extract_attachments
      @message.attachments&.map do |attachment|
        hash =
          if attachment.inline?
            { cid: attachment.cid }
          else
            { filename: attachment.filename }
          end

        hash.merge(
          type: attachment.mime_type,
          content: Base64.encode64(attachment.decoded)
        )
      end
    end

    # How to Extract the (uparsed) value of the mail message fields.
    #
    # @return [String] version dependent method call
    def mail_field_value
      @mail_field_value ||=
        if check_version_of('mail', '> 2.7.0')
          %w[unparsed_value]
        elsif check_version_of('mail', '= 2.7.0')
          %w[instance_variable_get @unparsed_value]
        elsif check_version_of('mail', '< 2.7.0')
          %w[instance_variable_get @value]
        end
    end

    # Extract the (unparsed) value of the mail message fields.
    #
    # @param [Mail::Field] message_field
    #
    # @return [String/Boolean/Hash] with the field (unparsed) value
    def message_field_value_from(message_field)
      return if message_field.nil?

      message_field.public_send(*mail_field_value)
    end

    # Extract the value from the given options.
    #
    # @param [Hash/Array/Class] option
    #
    # @return [Hash/Array/Class] with the option value
    def option_value_from(option)
      if option.is_a?(Hash) && option[delivery_system]
        option[delivery_system]
      else
        option
      end
    end

    # Extract 'settings'. If it's a hash then it'll return the right
    # settings belongs to the delivery system. If it's not a hash it'll return
    # the given value. But if the value doesn't a hash it'll raise an error.
    #
    # @return [Hash] settings for Mail delivery_method
    def settings
      @settings ||= option_value_from(@delivery_settings)

      return {} if @settings.nil?

      unless @settings.is_a?(Hash)
        raise Error::WrongDeliverySettings,
              '"delivery_settings" does not a Hash'
      end

      @settings
    end
  end
end
