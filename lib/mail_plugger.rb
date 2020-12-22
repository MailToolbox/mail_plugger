# frozen_string_literal: true

require 'mail_plugger/error'
require 'mail_plugger/mail_helper'
require 'mail_plugger/delivery_method'
# If we are using this gem outside of Rails then do not load this code.
require 'mail_plugger/railtie' if defined?(Rails)
require 'mail_plugger/version'

module MailPlugger
  class << self
    attr_reader :delivery_options, :client

    # Plug in defined API(s) class.
    #
    # @param [String] delivery_system the name of the API
    #
    # @example using Rails config/initializers/mail_plugger.rb
    #
    # The defined API class should have an 'initializer' and a 'deliver' method.
    #   class DefinedApiClientClass
    #     def initialize(options = {}) # required
    #       @settings = { api_key: ENV['API_KEY'] }
    #       @massage_to = options[:to]
    #       @message_from = options[:from]
    #       @message_subject = options[:subject]
    #       @message_body_text = options[:text_part]
    #       @message_body_html = options[:html_part]
    #     end
    #
    #     def deliver # required
    #       API.new(@settings).client.post(generate_mail_hash)
    #     end
    #
    #     private
    #
    #     def generate_mail_hash
    #       {
    #         to: generate_recipients,
    #         from: {
    #           email: @message_from
    #         },
    #         subject: @message_subject,
    #         content: [
    #           {
    #             type: 'text/plain',
    #             value: @message_body_text
    #           },
    #           {
    #             type: 'text/html',
    #             value: @message_body_html
    #           }
    #         ]
    #       }
    #     end
    #
    #     def generate_recipients
    #       @massage_to.map do |to|
    #         {
    #           email: to
    #         }
    #       end
    #     end
    #   end
    #
    #   MailPlugger.plug_in('definedapi') do |api|
    #     # It will search these options in the Mail::Message object
    #     api.delivery_options = [:to, :from, :subject, :text_part, :html_part]
    #
    #     api.client = DefinedApiClientClass
    #   end
    #
    def plug_in(delivery_system)
      if delivery_system.nil? || delivery_system.strip.empty?
        raise Error::WrongDeliverySystem, 'Delivery system is nil or empty. ' \
          'You should provide correct MailPlugger.plug_in parameter'
      end

      @delivery_system = delivery_system

      yield self
    rescue NoMethodError => e
      raise Error::WrongPlugInOption, e.message
    end

    # Define 'delivery_options' and 'client' setter methods. These methods are
    # generating a hash where the key is the 'delivery_system'. This let us to
    # set/use more than one API.
    %w[delivery_options client].each do |method|
      define_method "#{method}=" do |value|
        variable = instance_variable_get("@#{method}")
        variable = instance_variable_set("@#{method}", {}) if variable.nil?
        variable[@delivery_system] = value
      end
    end
  end
end
