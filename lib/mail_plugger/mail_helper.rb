# frozen_string_literal: true

require 'base64'
require 'mail/indifferent_hash'

module MailPlugger
  module MailHelper
    DELIVERY_SETTINGS_KEYS = %i[
      fake_plugger_debug
      fake_plugger_raw_message
      fake_plugger_response
      fake_plugger_use_mail_grabber
      return_response
      smtp_settings
    ].freeze

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

      Mail::IndifferentHash.new(data)
    end

    # Tries to set up a default delivery system, if the 'delivery_system'
    # wasn't defined in the Mail::Message object and 'delivery_options',
    # 'client' and/or 'delivery_settings' is a hash, then it tries to get the
    # 'delivery_system' from the hashes.
    # Which means the MailPlugger.plugin method was used, probably.
    #
    # @return [Stirng] the first key from the extracted keys
    def default_delivery_system_get
      extract_keys&.first
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
    # 'delivery_options', 'client' and/or 'delivery_settings' is a hash and
    # 'delivery_settings' doesn't contain 'delivery_system' then raise error.
    #
    # @return [String] with the name of the delivery system
    def delivery_system
      @delivery_system ||=
        (@message && message_field_value_from(@message[:delivery_system])) ||
        @default_delivery_system

      delivery_system_value_check

      @delivery_system
    end

    # Check the given 'delivery_options', 'client' and 'delivery_settings' are
    # hashes and if one of that does then check the 'delivery_system' is valid
    # or not.
    # If the given 'delivery_system' is nil or doesn't match with extracted keys
    # then it will raise error.
    def delivery_system_value_check
      return unless need_delivery_system?

      if @delivery_system.nil?
        raise Error::WrongDeliverySystem,
              '"delivery_system" was not defined as a Mail::Message parameter'
      end

      return if extract_keys&.include?(@delivery_system)

      raise Error::WrongDeliverySystem,
            "\"delivery_system\" '#{@delivery_system}' does not exist"
    end

    # Check that 'delivery_settings' has 'delivery_system' key or not.
    # If 'delivery_settings' contains 'DELIVERY_SETTINGS_KEYS' then it retruns
    # false, else true.
    #
    # @return [Boolean] true/false
    def exclude_delivey_settings_keys?
      @delivery_settings.keys.none? do |key|
        DELIVERY_SETTINGS_KEYS.include?(key.to_sym)
      end
    end

    # Extract attachments.
    #
    # @return [Array] with extracted attachment hashes
    def extract_attachments
      @message.attachments&.map do |attachment|
        hash = attachment.inline? ? { cid: attachment.cid } : {}

        hash.merge(
          filename: attachment.filename,
          type: attachment.mime_type,
          content: Base64.encode64(attachment.decoded)
        )
      end
    end

    # Return 'delivery_systems' array if it is exist. If not then extract keys
    # from 'delivery_options', 'client' or 'delivery_settings',
    # depends on which is a hash. If none of these are hashes then returns nil.
    #
    # @return [Array/NilClass] with the keys from one of the hash
    def extract_keys
      return @delivery_systems unless @delivery_systems.nil?

      if @delivery_options.is_a?(Hash)
        @delivery_options
      elsif @client.is_a?(Hash)
        @client
      elsif @delivery_settings.is_a?(Hash) && exclude_delivey_settings_keys?
        @delivery_settings
      end&.keys
    end

    # How to Extract the (unparsed) value of the mail message fields.
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

    # Check if either 'deliviery_options' or 'client' is a hash.
    # Or delivery_settings is a hash but not contains DELIVERY_SETTINGS_KEYS in
    # first level.
    #
    # @return [Boolean] true/false
    def need_delivery_system?
      @delivery_options.is_a?(Hash) ||
        @client.is_a?(Hash) ||
        (@delivery_settings.is_a?(Hash) && exclude_delivey_settings_keys?)
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

    # Check that settings contains any SMTP related settings.
    #
    # @return [Boolean] true/false
    def send_via_smtp?
      return true if settings[:smtp_settings].is_a?(Hash) &&
                     settings[:smtp_settings].any?

      false
    end

    # Extract 'settings'. If it's a hash then it'll return the right
    # settings belongs to the delivery system. If 'delivery_settings' is nil
    # it'll return an empty hash. But if the value doesn't a hash it'll raise
    # an error.
    #
    # @return [Hash] settings for Mail delivery_method and/or FakePlugger
    def settings
      @settings ||= option_value_from(@delivery_settings)

      return {} if @settings.nil?

      return @delivery_settings if should_return_delivery_settings?

      unless @settings.is_a?(Hash)
        raise Error::WrongDeliverySettings,
              '"delivery_settings" does not a Hash'
      end

      @settings
    end

    # For FakePlugger in the initialize method sometimes the extracted
    # 'settings' value is wrong because we need that hash what we added to the
    # 'delivery_settings'.
    #
    # @return [Boolean] true/false
    def should_return_delivery_settings?
      @delivery_settings.is_a?(Hash) && !@settings.is_a?(Hash) && @initialize
    end
  end
end
