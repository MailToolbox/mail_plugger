# frozen_string_literal: true

require 'mail_plugger/error'
require 'mail_plugger/mail_helper'
require 'mail_plugger/delivery_method'
# If we are using this gem outside of Rails then do not load this code.
require 'mail_plugger/railtie' if defined?(Rails)
require 'mail_plugger/version'

require 'fake_plugger/delivery_method'
# If we are using this gem outside of Rails then do not load this code.
require 'fake_plugger/railtie' if defined?(Rails)

module MailPlugger
  class << self
    attr_reader :client, :delivery_options, :delivery_settings

    # Plug in defined API(s) class.
    #
    # @param [String/Symbol] delivery_system the name of the API
    #
    # @example using Rails `config/initializers/mail_plugger.rb`
    #
    #   # The defined API class should have an 'initialize' and a 'deliver'
    #   # method.
    #   class DefinedApiClientClass
    #     def initialize(options = {})
    #       @settings = { api_key: '12345' }
    #       @options = options
    #     end
    #
    #     def deliver
    #       API.new(@settings).client.post(generate_mail_hash)
    #     end
    #
    #     private
    #
    #     def generate_mail_hash
    #       {
    #         to: generate_recipients,
    #         from: {
    #           email: @options[:from].first
    #         },
    #         subject: @options[:subject],
    #         content: [
    #           {
    #             type: 'text/plain',
    #             value: @options[:text_part]
    #           },
    #           {
    #             type: 'text/html; charset=UTF-8',
    #             value: @options[:html_part]
    #           }
    #         ]
    #       }
    #     end
    #
    #     def generate_recipients
    #       @options[:to].map do |to|
    #         {
    #           email: to
    #         }
    #       end
    #     end
    #   end
    #
    #   MailPlugger.plug_in('defined_api') do |api|
    #     # It will search these options in the Mail::Message object
    #     api.delivery_options = [:to, :from, :subject, :text_part, :html_part]
    #     api.delivery_settings = { return_response: true }
    #     api.client = DefinedApiClientClass
    #   end
    #
    def plug_in(delivery_system)
      check_value(delivery_system)

      @delivery_system = delivery_system

      yield self
    rescue NoMethodError => e
      raise Error::WrongPlugInOption, e.message
    end

    # Define 'client', 'delivery_options' and 'delivery_settings' setter
    # methods. These methods are generating a hash where the key is the
    # 'delivery_system'. This let us to set/use more than one API.
    %w[client delivery_options delivery_settings].each do |method|
      define_method "#{method}=" do |value|
        variable = instance_variable_get("@#{method}")
        variable = instance_variable_set("@#{method}", {}) if variable.nil?
        variable[@delivery_system] = value
      end
    end

    private

    # Check 'delivery_system' is valid or not. If it's not valid then
    # it will raise an error.
    #
    # @param [String/Symbol] delivery_system the name of the API
    def check_value(delivery_system)
      if delivery_system.nil?
        raise Error::WrongDeliverySystem, '"delivery_system" is nil'
      end

      if delivery_system.is_a?(String) && delivery_system.strip.empty?
        raise Error::WrongDeliverySystem, '"delivery_system" is empty'
      end

      return if delivery_system.is_a?(String) || delivery_system.is_a?(Symbol)

      raise Error::WrongDeliverySystem, '"delivery_system" does not a ' \
        'String or Symbol'
    end
  end
end
