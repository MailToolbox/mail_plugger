# frozen_string_literal: true

require 'spec_helper'
require 'shared_examples/mail_plugger/delivery_method/initialize/' \
        'without_initialize_arguments'
require 'shared_examples/mail_plugger/delivery_method/initialize/' \
        'with_initialize_arguments'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'without_initialize_arguments/when_using_smtp'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'without_initialize_arguments/when_using_api'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'without_initialize_arguments/when_using_smtp_and_api'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'without_initialize_arguments/when_using_configure_method'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'with_initialize_arguments/when_using_smtp'
require 'shared_examples/mail_plugger/delivery_method/deliver/' \
        'with_initialize_arguments/when_using_api'

RSpec.describe MailPlugger::DeliveryMethod do
  before { stub_const('DummyApi', dummy_api_class) }

  # rubocop:disable Style/RedundantInitialize
  let(:dummy_api_class) do
    Class.new do
      def initialize(options = {}); end

      def deliver; end
    end
  end
  # rubocop:enable Style/RedundantInitialize
  let(:client) { DummyApi }
  let(:delivery_options) { %i[to from subject body] }
  let(:delivery_settings) { { key: :value } }
  let(:default_delivery_options) { { tag: 'test_tag' } }
  let(:delivery_system) { 'delivery_system' }
  let(:default_delivery_system) { 'delivery_system' }
  let(:sending_method) { :default_delivery_system }

  describe '#initialize' do
    include_examples 'mail_plugger/delivery_method/initialize/' \
                     'without_initialize_arguments'
    include_examples 'mail_plugger/delivery_method/initialize/' \
                     'with_initialize_arguments'
  end

  describe '#deliver!' do
    context 'without initialize arguments' do
      context 'when using MailPlugger.plug_in method' do
        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        include_examples 'mail_plugger/delivery_method/deliver/' \
                         'without_initialize_arguments/when_using_smtp'

        include_examples 'mail_plugger/delivery_method/deliver/' \
                         'without_initialize_arguments/when_using_api'

        include_examples 'mail_plugger/delivery_method/deliver/' \
                         'without_initialize_arguments/when_using_smtp_and_api'

        include_examples 'mail_plugger/delivery_method/deliver/' \
                         'without_initialize_arguments/' \
                         'when_using_configure_method'
      end

      context 'when NOT using MailPlugger.plug_in method' do
        context 'and without deliver! method paramemter' do
          subject(:deliver) { described_class.new.deliver! }

          it 'raises error' do
            expect { deliver }.to raise_error(ArgumentError)
          end
        end

        context 'and the deliver! method has paramemter' do
          subject(:deliver) { described_class.new.deliver!(message) }

          context 'and message paramemter does NOT a Mail::Message object' do
            let(:message) { nil }

            it 'raises error' do
              expect { deliver }
                .to raise_error(MailPlugger::Error::WrongParameter)
            end
          end

          context 'and message paramemter is a Mail::Message object' do
            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              it 'raises error' do
                expect { deliver }
                  .to raise_error(MailPlugger::Error::WrongApiClient)
              end
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongApiClient)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongApiClient)
                end
              end
            end
          end
        end
      end
    end

    context 'with initialize arguments' do
      include_examples 'mail_plugger/delivery_method/deliver/' \
                       'with_initialize_arguments/when_using_smtp'

      include_examples 'mail_plugger/delivery_method/deliver/' \
                       'with_initialize_arguments/when_using_api'
    end
  end
end
