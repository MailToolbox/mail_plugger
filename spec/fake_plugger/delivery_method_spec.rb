# frozen_string_literal: true

require 'spec_helper'

RSpec.describe FakePlugger::DeliveryMethod do
  before do
    stub_const('DummyApi', dummy_api_class)
    stub_const('MailGrabber::DeliveryMethod', mail_grabber_class)
  end

  let(:dummy_api_class) do
    Class.new do
      def initialize(options = {}); end

      def deliver; end
    end
  end
  let(:mail_grabber_class) do
    Class.new do
      def initialize(options = {}); end

      def deliver!(message); end
    end
  end
  let(:delivery_system) { 'dummy_api' }
  let(:delivery_options) { %i[to from subject body] }
  let(:delivery_settings) do
    {
      fake_plugger_debug: true,
      fake_plugger_raw_message: true,
      fake_plugger_use_mail_grabber: true,
      fake_plugger_response: { response: 'OK' }
    }
  end
  let(:client) { DummyApi }

  describe '#initialize' do
    context 'without initialize arguments' do
      subject(:init_method) { described_class.new }

      context 'when using MailPlugger.plug_in method' do
        before do
          MailPlugger.plug_in(delivery_system) do |api|
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end
        end

        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        it 'sets delivery_options with expected value' do
          expect(init_method.instance_variable_get('@delivery_options'))
            .to eq({ delivery_system => delivery_options })
        end

        it 'sets client with expected value' do
          expect(init_method.instance_variable_get('@client'))
            .to eq({ delivery_system => DummyApi })
        end

        it 'sets default_delivery_system with expected value' do
          expect(init_method.instance_variable_get('@default_delivery_system'))
            .to eq(delivery_system)
        end

        it 'sets delivery_settings with expected value' do
          expect(init_method.instance_variable_get('@delivery_settings'))
            .to eq({ delivery_system => delivery_settings })
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get('@message')).to be nil
        end

        it 'sets debug with expected value' do
          expect(init_method.instance_variable_get('@debug'))
            .to eq(delivery_settings[:fake_plugger_debug])
        end

        it 'sets raw_message with expected value' do
          expect(init_method.instance_variable_get('@raw_message'))
            .to eq(delivery_settings[:fake_plugger_raw_message])
        end

        it 'sets response with expected value' do
          expect(init_method.instance_variable_get('@response'))
            .to eq(delivery_settings[:fake_plugger_response])
        end

        it 'sets use_mail_grabber with expected value' do
          expect(init_method.instance_variable_get('@use_mail_grabber'))
            .to eq(delivery_settings[:fake_plugger_use_mail_grabber])
        end
      end

      context 'when NOT using MailPlugger.plug_in method' do
        it 'does NOT set delivery_options' do
          expect(init_method.instance_variable_get('@delivery_options'))
            .to be nil
        end

        it 'does NOT set client' do
          expect(init_method.instance_variable_get('@client')).to be nil
        end

        it 'does NOT set default_delivery_system' do
          expect(init_method.instance_variable_get('@default_delivery_system'))
            .to be nil
        end

        it 'does NOT set delivery_settings' do
          expect(init_method.instance_variable_get('@delivery_settings'))
            .to be nil
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get('@message')).to be nil
        end

        it 'sets debug with false' do
          expect(init_method.instance_variable_get('@debug')).to be false
        end

        it 'sets raw_message with false' do
          expect(init_method.instance_variable_get('@raw_message')).to be false
        end

        it 'does NOT set response' do
          expect(init_method.instance_variable_get('@response')).to be nil
        end

        it 'sets use_mail_grabber with false' do
          expect(init_method.instance_variable_get('@use_mail_grabber'))
            .to be false
        end
      end
    end

    context 'with initialize arguments' do
      subject(:init_method) do
        described_class.new(
          delivery_options: delivery_options,
          client: client,
          default_delivery_system: delivery_system,
          delivery_settings: delivery_settings
        )
      end

      shared_examples 'arguments' do
        it 'sets delivery_options with given value' do
          expect(init_method.instance_variable_get('@delivery_options'))
            .to eq(delivery_options)
        end

        it 'sets client with given value' do
          expect(init_method.instance_variable_get('@client')).to eq(client)
        end

        it 'sets default_delivery_system with given value' do
          expect(init_method.instance_variable_get('@default_delivery_system'))
            .to eq(delivery_system)
        end

        it 'sets delivery_settings with given value' do
          expect(init_method.instance_variable_get('@delivery_settings'))
            .to eq(delivery_settings)
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get('@message')).to be nil
        end

        it 'sets debug with given value' do
          expect(init_method.instance_variable_get('@debug'))
            .to eq(delivery_settings[:fake_plugger_debug])
        end

        it 'sets raw_message with given value' do
          expect(init_method.instance_variable_get('@raw_message'))
            .to eq(delivery_settings[:fake_plugger_raw_message])
        end

        it 'sets response with given value' do
          expect(init_method.instance_variable_get('@response'))
            .to eq(delivery_settings[:fake_plugger_response])
        end

        it 'sets use_mail_grabber with expected value' do
          expect(init_method.instance_variable_get('@use_mail_grabber'))
            .to eq(delivery_settings[:fake_plugger_use_mail_grabber])
        end
      end

      context 'when using MailPlugger.plug_in method' do
        before do
          MailPlugger.plug_in('different_api') do |api|
            api.delivery_options = 'different options'
            api.delivery_settings = 'different settings'
            api.client = 'different client'
          end
        end

        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        it_behaves_like 'arguments'
      end

      context 'when NOT using MailPlugger.plug_in method' do
        it_behaves_like 'arguments'
      end
    end
  end

  describe '#deliver!' do
    context 'when sets debug option' do
      before { delivery_settings[:fake_plugger_raw_message] = false }

      let(:message) { Mail.new }

      shared_examples 'debug mode' do
        # rubocop:disable RSpec/AnyInstance
        context 'and debug mode is swiched off' do
          before { delivery_settings[:fake_plugger_debug] = false }

          it 'does NOT call show_debug_info method' do
            expect_any_instance_of(described_class)
              .not_to receive(:show_debug_info)
            deliver
          end
        end

        context 'and debug mode is swiched on' do
          it 'calls show_debug_info method' do
            expect_any_instance_of(described_class)
              .to receive(:show_debug_info)
              .and_call_original
            expect_any_instance_of(described_class).to receive(:puts)
            deliver
          end
        end
        # rubocop:enable RSpec/AnyInstance
      end

      context 'and using SMTP' do
        before { delivery_settings[:smtp_settings] = { key: 'value' } }

        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |smtp|
              smtp.delivery_settings = delivery_settings
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'debug mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets debug value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'debug mode'
          end

          context 'and sets debug value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings.slice(:smtp_settings),
                debug: delivery_settings[:fake_plugger_debug]
              ).deliver!(message)
            end

            it_behaves_like 'debug mode'
          end
        end
      end

      context 'and using API' do
        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |api|
              api.delivery_options = delivery_options
              api.delivery_settings = delivery_settings
              api.client = client
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'debug mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets debug value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'debug mode'
          end

          context 'and sets debug value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                debug: delivery_settings[:fake_plugger_debug]
              ).deliver!(message)
            end

            it_behaves_like 'debug mode'
          end
        end
      end
    end

    context 'when sets raw_message option' do
      before { delivery_settings[:fake_plugger_debug] = false }

      let(:message) { Mail.new }

      shared_examples 'raw_message mode' do
        # rubocop:disable RSpec/AnyInstance
        context 'and raw_message mode is swiched off' do
          before { delivery_settings[:fake_plugger_raw_message] = false }

          it 'does NOT call show_raw_message method' do
            expect_any_instance_of(described_class)
              .not_to receive(:show_raw_message)
            deliver
          end
        end

        context 'and raw_message mode is swiched on' do
          it 'calls show_raw_message method' do
            expect_any_instance_of(described_class)
              .to receive(:show_raw_message)
              .and_call_original
            expect_any_instance_of(described_class).to receive(:puts)
            deliver
          end
        end
        # rubocop:enable RSpec/AnyInstance
      end

      context 'and using SMTP' do
        before { delivery_settings[:smtp_settings] = { key: 'value' } }

        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |smtp|
              smtp.delivery_settings = delivery_settings
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'raw_message mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets raw_message value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'raw_message mode'
          end

          context 'and sets raw_message value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings.slice(:smtp_settings),
                raw_message: delivery_settings[:fake_plugger_raw_message]
              ).deliver!(message)
            end

            it_behaves_like 'raw_message mode'
          end
        end
      end

      context 'and using API' do
        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |api|
              api.delivery_options = delivery_options
              api.delivery_settings = delivery_settings
              api.client = client
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'raw_message mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets raw_message value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'raw_message mode'
          end

          context 'and sets raw_message value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                raw_message: delivery_settings[:fake_plugger_raw_message]
              ).deliver!(message)
            end

            it_behaves_like 'raw_message mode'
          end
        end
      end
    end

    context 'when sets response option' do
      before do
        delivery_settings[:fake_plugger_debug] = false
        delivery_settings[:fake_plugger_raw_message] = false
      end

      let(:message) do
        Mail.new(
          from: 'from@example.com',
          to: 'to@example.com',
          subject: 'This is the message subject',
          body: 'This is the message body'
        )
      end
      let(:expected_hash) do
        {
          'from' => ['from@example.com'],
          'to' => ['to@example.com'],
          'subject' => 'This is the message subject',
          'body' => 'This is the message body'
        }
      end

      shared_examples 'fake response' do |use_settings_method, delivery_method|
        shared_examples 'expected method calls' do |use_delivery_data|
          # rubocop:disable RSpec/AnyInstance
          it 'does NOT call client method' do
            expect_any_instance_of(MailPlugger::MailHelper)
              .not_to receive(:client)
            deliver
          end

          if use_settings_method == 'and using settings'
            # Because of the settings method calls delivery_system method
            it 'calls delivery_system method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .to receive(:delivery_system)
                .at_least(:once)
                .and_return(delivery_system)
              deliver
            end
          else
            it 'does NOT call delivery_system method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .not_to receive(:delivery_system)
              deliver
            end
          end

          if use_delivery_data == 'and returns with delivery_data' &&
             delivery_method == 'API'
            it 'calls delivery_options method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .to receive(:delivery_options)
                .at_least(:once)
                .and_return(delivery_options)
              deliver
            end

            it 'calls delivery_data method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .to receive(:delivery_data)
              deliver
            end
          else
            it 'does NOT call delivery_options method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .not_to receive(:delivery_options)
              deliver
            end

            it 'does NOT call delivery_data method' do
              expect_any_instance_of(MailPlugger::MailHelper)
                .not_to receive(:delivery_data)
              deliver
            end
          end
          # rubocop:enable RSpec/AnyInstance

          it 'does NOT call the new method of the client' do
            expect(client).not_to receive(:new)
            deliver
          end
        end

        context 'and does NOT set the response value' do
          before { delivery_settings[:fake_plugger_response] = nil }

          if delivery_method == 'SMTP'
            it 'calls the delivery_method method of the message' do
              expect(message).to receive(:delivery_method)
              deliver
            end
          else
            it 'calls the new method of the client' do
              expect(client).to receive(:new)
              deliver
            end
          end
        end

        context 'and sets response with return_delivery_data' do
          before do
            delivery_settings[:fake_plugger_response] = {
              return_delivery_data: true
            }
          end

          if delivery_method == 'SMTP'
            it 'returns with response value' do
              expect(deliver).to eq(delivery_settings[:fake_plugger_response])
            end
          else
            it 'returns with delivery_data hash' do
              expect(deliver).to eq(expected_hash)
            end
          end

          it_behaves_like 'expected method calls',
                          'and returns with delivery_data'
        end

        context 'and sets response with anything else' do
          it 'returns with the given response value' do
            expect(deliver).to eq(delivery_settings[:fake_plugger_response])
          end

          it_behaves_like 'expected method calls',
                          'and does NOT retrun with delivery_data'
        end
      end

      context 'and using SMTP' do
        before { delivery_settings[:smtp_settings] = { key: 'value' } }

        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |smtp|
              smtp.delivery_settings = delivery_settings
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'fake response', 'and using settings', 'SMTP'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets response value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'fake response', 'and using settings', 'SMTP'
          end

          context 'and sets response value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings.slice(:smtp_settings),
                response: delivery_settings[:fake_plugger_response]
              ).deliver!(message)
            end

            it_behaves_like 'fake response', 'and using settings', 'SMTP'
          end
        end
      end

      context 'and using API' do
        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |api|
              api.delivery_options = delivery_options
              api.delivery_settings = delivery_settings
              api.client = client
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'fake response', 'and using settings', 'API'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets response value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'fake response', 'and using settings', 'API'
          end

          context 'and sets response value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                response: delivery_settings[:fake_plugger_response]
              ).deliver!(message)
            end

            it_behaves_like 'fake response', 'and NOT using settings', 'API'
          end
        end
      end
    end

    context 'when sets use_mail_grabber option' do
      before do
        delivery_settings[:fake_plugger_debug] = false
        delivery_settings[:fake_plugger_raw_message] = false
      end

      let(:message) { Mail.new }

      shared_examples 'use_mail_grabber mode' do
        context 'and mail_grabber gem installed' do
          before { allow(Gem.loaded_specs).to receive(:key?).and_return(true) }

          context 'and use_mail_grabber mode is swiched off' do
            before { delivery_settings[:fake_plugger_use_mail_grabber] = false }

            it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
              expect(MailGrabber::DeliveryMethod).not_to receive(:new)
              deliver
            end
          end

          context 'and use_mail_grabber mode is swiched on' do
            it 'calls deliver! method of MailGrabber::DeliveryMethod' do
              expect(MailGrabber::DeliveryMethod)
                .to receive_message_chain(:new, :deliver!)
              deliver
            end
          end
        end

        context 'and mail_grabber gem does NOT installed' do
          before { allow(Gem.loaded_specs).to receive(:key?).and_return(false) }

          context 'and use_mail_grabber mode is swiched off' do
            before { delivery_settings[:fake_plugger_use_mail_grabber] = false }

            it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
              expect(MailGrabber::DeliveryMethod).not_to receive(:new)
              deliver
            end
          end

          context 'and use_mail_grabber mode is swiched on' do
            it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
              expect(MailGrabber::DeliveryMethod).not_to receive(:new)
              deliver
            end
          end
        end
      end

      context 'and using SMTP' do
        before { delivery_settings[:smtp_settings] = { key: 'value' } }

        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |smtp|
              smtp.delivery_settings = delivery_settings
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'use_mail_grabber mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets use_mail_grabber value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'use_mail_grabber mode'
          end

          context 'and sets use_mail_grabber value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_settings: delivery_settings.slice(:smtp_settings),
                use_mail_grabber:
                  delivery_settings[:fake_plugger_use_mail_grabber]
              ).deliver!(message)
            end

            it_behaves_like 'use_mail_grabber mode'
          end
        end
      end

      context 'and using API' do
        context 'and using MailPlugger.plug_in method' do
          subject(:deliver) { described_class.new.deliver!(message) }

          before do
            MailPlugger.plug_in(delivery_system) do |api|
              api.delivery_options = delivery_options
              api.delivery_settings = delivery_settings
              api.client = client
            end
          end

          after do
            MailPlugger.instance_variables.each do |variable|
              MailPlugger.remove_instance_variable(variable)
            end
          end

          it_behaves_like 'use_mail_grabber mode'
        end

        context 'and NOT using MailPlugger.plug_in method' do
          context 'and sets use_mail_grabber value via settings' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            it_behaves_like 'use_mail_grabber mode'
          end

          context 'and sets use_mail_grabber value via options' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                use_mail_grabber:
                  delivery_settings[:fake_plugger_use_mail_grabber]
              ).deliver!(message)
            end

            it_behaves_like 'use_mail_grabber mode'
          end
        end
      end
    end

    context 'when it behaves like MailPlugger::DeliveryMethod' do
      context 'without initialize arguments' do
        context 'when using SMTP' do
          let(:delivery_settings) { { smtp_settings: { key: 'value' } } }

          context 'when using MailPlugger.plug_in method' do
            before do
              MailPlugger.plug_in(delivery_system) do |smtp|
                smtp.delivery_settings = delivery_settings
              end
            end

            after do
              MailPlugger.instance_variables.each do |variable|
                MailPlugger.remove_instance_variable(variable)
              end
            end

            context 'and without deliver! method paramemter' do
              subject(:deliver) { described_class.new.deliver! }

              it 'raises error' do
                expect { deliver }.to raise_error(ArgumentError)
              end
            end

            context 'and the deliver! method has paramemter' do
              subject(:deliver) { described_class.new.deliver!(message) }

              context 'and message paramemter does NOT a Mail::Message ' \
                      'object' do
                let(:message) { nil }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongParameter)
                end
              end

              context 'and message paramemter is a Mail::Message object' do
                before { allow(message).to receive(:deliver!) }

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'returns with the message' do
                    expect(deliver).to eq(message)
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'raises error' do
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    context 'and delivery_system value is string' do
                      let(:delivery_system) { 'dummy_api' }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'returns with the message' do
                        expect(deliver).to eq(message)
                      end
                    end

                    context 'and delivery_system value is symbol' do
                      let(:delivery_system) { :dummy_api }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'returns with the message' do
                        expect(deliver).to eq(message)
                      end
                    end
                  end
                end
              end
            end
          end
        end

        context 'when using API' do
          context 'when using MailPlugger.plug_in method' do
            before do
              MailPlugger.plug_in(delivery_system) do |api|
                api.delivery_options = delivery_options
                api.client = client
              end
            end

            after do
              MailPlugger.instance_variables.each do |variable|
                MailPlugger.remove_instance_variable(variable)
              end
            end

            context 'and without deliver! method paramemter' do
              subject(:deliver) { described_class.new.deliver! }

              it 'raises error' do
                expect { deliver }.to raise_error(ArgumentError)
              end
            end

            context 'and the deliver! method has paramemter' do
              subject(:deliver) { described_class.new.deliver!(message) }

              context 'and message paramemter does NOT a Mail::Message ' \
                      'object' do
                let(:message) { nil }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongParameter)
                end
              end

              context 'and message paramemter is a Mail::Message object' do
                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls only the new method of the client' do
                    expect(client).to receive(:new)
                    deliver
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'raises error' do
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    context 'and delivery_system value is string' do
                      let(:delivery_system) { 'dummy_api' }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end

                    context 'and delivery_system value is symbol' do
                      let(:delivery_system) { :dummy_api }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end
              end
            end
          end
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
        context 'when using SMTP' do
          context 'and without deliver! method paramemter' do
            subject(:deliver) do
              described_class.new(
                default_delivery_system: delivery_system,
                delivery_settings: delivery_settings
              ).deliver!
            end

            it 'raises error' do
              expect { deliver }.to raise_error(ArgumentError)
            end
          end

          context 'and the deliver! method has paramemter' do
            subject(:deliver) do
              described_class.new(
                default_delivery_system: default_delivery_system,
                delivery_settings: delivery_settings
              ).deliver!(message)
            end

            context 'but message paramemter does NOT a Mail::Message object' do
              let(:default_delivery_system) { nil }
              let(:message) { nil }

              it 'raises error' do
                expect { deliver }
                  .to raise_error(MailPlugger::Error::WrongParameter)
              end
            end

            context 'and message paramemter is a Mail::Message object' do
              before { allow(message).to receive(:deliver!) }

              context 'and default_delivery_system does NOT defined' do
                let(:default_delivery_system) { nil }

                context 'when delivery_settings is a hash' do
                  context 'and delivery_settings does NOT contain ' \
                          'delivery_system' do
                    context 'and delivery_settings does NOT contain ' \
                            'smtp_settings' do
                      context 'but delivery_settings contains ' \
                              'one of DELIVERY_SETTINGS_KEYS' do
                        let(:delivery_settings) { { return_response: true } }

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end

                      context 'and delivery_settings does NOT contain ' \
                              'DELIVERY_SETTINGS_KEYS (in the first level)' do
                        let(:delivery_settings) { { key: 'value' } }

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongDeliverySettings
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end
                        end
                      end
                    end

                    context 'and delivery_settings contains smtp_settings' do
                      let(:delivery_settings) do
                        {
                          smtp_settings: { key: 'value' },
                          return_response: true
                        }
                      end

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'returns with the message' do
                          expect(deliver).to eq(message)
                        end
                      end

                      context 'and message contains delivery_system' do
                        # In this case delivey_settings does not contain
                        # delivery_system, so the delivey_system is not
                        # important.
                        context 'but the given delivery_system does NOT ' \
                                'exist' do
                          let(:message) { Mail.new(delivery_system: 'key') }

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end

                        context 'and the given delivery_system exists' do
                          let(:message) do
                            Mail.new(delivery_system: delivery_system)
                          end

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end
                      end
                    end
                  end

                  context 'and delivery_settings contains delivery_system' do
                    context 'and delivery_settings does NOT contain ' \
                            'smtp_settings' do
                      context 'but delivery_settings contains ' \
                              'one of DELIVERY_SETTINGS_KEYS' do
                        let(:delivery_settings) do
                          { delivery_system => { return_response: true } }
                        end

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end

                      context 'and delivery_settings does NOT contain ' \
                              'DELIVERY_SETTINGS_KEYS (in the first level)' do
                        let(:delivery_settings) do
                          { delivery_system => { key: 'value' } }
                        end

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end
                    end

                    context 'and delivery_settings contains smtp_settings' do
                      let(:delivery_settings) do
                        {
                          delivery_system => {
                            smtp_settings: { key: 'value' },
                            return_response: true
                          }
                        }
                      end

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'returns with the message' do
                          expect(deliver).to eq(message)
                        end
                      end

                      context 'and message contains delivery_system' do
                        context 'but the given delivery_system does NOT ' \
                                'exist' do
                          let(:message) { Mail.new(delivery_system: 'key') }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongDeliverySystem
                            )
                          end
                        end

                        context 'and the given delivery_system exists' do
                          let(:message) do
                            Mail.new(delivery_system: delivery_system)
                          end

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end
                      end
                    end
                  end
                end

                context 'when delivery_settings does NOT a hash' do
                  context 'and delivery_settings is nil' do
                    let(:delivery_settings) { nil }

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end

                    context 'and message contains delivery_system' do
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongApiClient
                          )
                        end
                      end

                      context 'and the given delivery_system exists' do
                        let(:message) do
                          Mail.new(delivery_system: delivery_system)
                        end

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongApiClient
                          )
                        end
                      end
                    end
                  end

                  context 'and delivery_settings is string' do
                    let(:delivery_settings) { 'settings' }

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySettings
                        )
                      end
                    end

                    context 'and message contains delivery_system' do
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongDeliverySettings
                          )
                        end
                      end

                      context 'and the given delivery_system exists' do
                        let(:message) do
                          Mail.new(delivery_system: delivery_system)
                        end

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongDeliverySettings
                          )
                        end
                      end
                    end
                  end
                end
              end

              context 'and default_delivery_system is defined' do
                let(:default_delivery_system) { delivery_system }

                context 'when delivery_settings is a hash' do
                  context 'and delivery_settings does NOT contain ' \
                          'delivery_system' do
                    context 'and delivery_settings does NOT contain ' \
                            'smtp_settings' do
                      context 'but delivery_settings contains ' \
                              'one of DELIVERY_SETTINGS_KEYS' do
                        let(:delivery_settings) { { return_response: true } }

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end

                      context 'and delivery_settings does NOT contain ' \
                              'DELIVERY_SETTINGS_KEYS (in the first level)' do
                        let(:delivery_settings) { { key: 'value' } }

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongDeliverySystem
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end
                        end
                      end
                    end

                    context 'and delivery_settings contains smtp_settings' do
                      let(:delivery_settings) do
                        {
                          smtp_settings: { key: 'value' },
                          return_response: true
                        }
                      end

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'returns with the message' do
                          expect(deliver).to eq(message)
                        end
                      end

                      context 'and message contains delivery_system' do
                        # In this case delivey_settings does not contain
                        # delivery_system, so the delivey_system is not
                        # important.
                        context 'but the given delivery_system does NOT ' \
                                'exist' do
                          let(:message) { Mail.new(delivery_system: 'key') }

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end

                        context 'and the given delivery_system exists' do
                          let(:message) do
                            Mail.new(delivery_system: delivery_system)
                          end

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end
                      end
                    end
                  end

                  context 'and delivery_settings contains delivery_system' do
                    context 'and delivery_settings does NOT contain ' \
                            'smtp_settings' do
                      context 'but delivery_settings contains ' \
                              'one of DELIVERY_SETTINGS_KEYS' do
                        let(:delivery_settings) do
                          { delivery_system => { return_response: true } }
                        end

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end

                      context 'and delivery_settings does NOT contain ' \
                              'DELIVERY_SETTINGS_KEYS (in the first level)' do
                        let(:delivery_settings) do
                          { delivery_system => { key: 'value' } }
                        end

                        context 'but message does NOT contain ' \
                                'delivery_system' do
                          let(:message) { Mail.new }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongApiClient
                            )
                          end
                        end

                        context 'and message contains delivery_system' do
                          context 'but the given delivery_system does NOT ' \
                                  'exist' do
                            let(:message) { Mail.new(delivery_system: 'key') }

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongDeliverySystem
                              )
                            end
                          end

                          context 'and the given delivery_system exists' do
                            let(:message) do
                              Mail.new(delivery_system: delivery_system)
                            end

                            it 'raises error' do
                              expect { deliver }.to raise_error(
                                MailPlugger::Error::WrongApiClient
                              )
                            end
                          end
                        end
                      end
                    end

                    context 'and delivery_settings contains smtp_settings' do
                      let(:delivery_settings) do
                        {
                          delivery_system => {
                            smtp_settings: { key: 'value' },
                            return_response: true
                          }
                        }
                      end

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'returns with the message' do
                          expect(deliver).to eq(message)
                        end
                      end

                      context 'and message contains delivery_system' do
                        context 'but the given delivery_system does NOT ' \
                                'exist' do
                          let(:message) { Mail.new(delivery_system: 'key') }

                          it 'raises error' do
                            expect { deliver }.to raise_error(
                              MailPlugger::Error::WrongDeliverySystem
                            )
                          end
                        end

                        context 'and the given delivery_system exists' do
                          let(:message) do
                            Mail.new(delivery_system: delivery_system)
                          end

                          it 'does NOT raise error' do
                            expect { deliver }.not_to raise_error
                          end

                          it 'returns with the message' do
                            expect(deliver).to eq(message)
                          end
                        end
                      end
                    end
                  end
                end

                context 'when delivery_settings does NOT a hash' do
                  context 'and delivery_settings is nil' do
                    let(:delivery_settings) { nil }

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end

                    context 'and message contains delivery_system' do
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongApiClient
                          )
                        end
                      end

                      context 'and the given delivery_system exists' do
                        let(:message) do
                          Mail.new(delivery_system: delivery_system)
                        end

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongApiClient
                          )
                        end
                      end
                    end
                  end

                  context 'and delivery_settings is string' do
                    let(:delivery_settings) { 'settings' }

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySettings
                        )
                      end
                    end

                    context 'and message contains delivery_system' do
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongDeliverySettings
                          )
                        end
                      end

                      context 'and the given delivery_system exists' do
                        let(:message) do
                          Mail.new(delivery_system: delivery_system)
                        end

                        it 'raises error' do
                          expect { deliver }.to raise_error(
                            MailPlugger::Error::WrongDeliverySettings
                          )
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        context 'when using API' do
          context 'and without deliver! method paramemter' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                default_delivery_system: delivery_system
              ).deliver!
            end

            it 'raises error' do
              expect { deliver }.to raise_error(ArgumentError)
            end
          end

          context 'and the deliver! method has paramemter' do
            subject(:deliver) do
              described_class.new(
                delivery_options: delivery_options,
                client: client,
                default_delivery_system: default_delivery_system
              ).deliver!(message)
            end

            context 'but message paramemter does NOT a Mail::Message object' do
              let(:default_delivery_system) { nil }
              let(:message) { nil }

              it 'raises error' do
                expect { deliver }
                  .to raise_error(MailPlugger::Error::WrongParameter)
              end
            end

            context 'and message paramemter is a Mail::Message object' do
              context 'and default_delivery_system does NOT defined' do
                let(:default_delivery_system) { nil }

                context 'when both delivery_options and client are hashes' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end
                  let(:client) { { delivery_system => DummyApi } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    # It won't raise error because it gets delivery_system from
                    # the hash key
                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(DummyApi).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(DummyApi).to receive(:new)
                        deliver
                      end
                    end
                  end
                end

                context 'when one of the delivery_options and client is a ' \
                        'hash' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(client).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end

                context 'when none of the delivery_options and client are ' \
                        'hashes' do
                  # In this case delivey_options and client are not hashes,
                  # so the delivey_system is not important.
                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(client).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end
              end

              context 'and default_delivery_system is defined' do
                let(:default_delivery_system) { delivery_system }

                context 'when both delivery_options and client are hashes' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end
                  let(:client) { { delivery_system => DummyApi } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    # It won't raise error because the default_delivery_system
                    # is defined
                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(DummyApi).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      # It raises error because it overrides the
                      # default_delivery_system
                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      context 'and delivery_system value is string' do
                        let(:delivery_system) { 'dummy_api' }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'calls only the new method of the client' do
                          expect(DummyApi).to receive(:new)
                          deliver
                        end
                      end

                      context 'and delivery_system value is symbol' do
                        let(:delivery_system) { :dummy_api }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'calls only the new method of the client' do
                          expect(DummyApi).to receive(:new)
                          deliver
                        end
                      end
                    end
                  end
                end

                context 'when one of the delivery_options and client is a ' \
                        'hash' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    # It won't raise error because the default_delivery_system
                    # is defined
                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(client).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end

                context 'when none of the delivery_options and client are ' \
                        'hashes' do
                  # In this case delivey_options and client are not hashes,
                  # so the delivey_system is not important.
                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(client).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end
              end

              context 'and default_delivery_system is defined but with a ' \
                      'wrong value' do
                let(:default_delivery_system) { 'wrong_value' }

                context 'when both delivery_options and client are hashes' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end
                  let(:client) { { delivery_system => DummyApi } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    # It raises error because the default_delivery_system is
                    # wrong and delivery_options method gets nil value which
                    # is not Array
                    it 'raises error' do
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      # It raises error because it overrides the
                      # default_delivery_system and this also wrong
                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(DummyApi).to receive(:new)
                        deliver
                      end
                    end
                  end
                end

                context 'when one of the delivery_options and client is a ' \
                        'hash' do
                  let(:delivery_options) do
                    { delivery_system => %i[to from subject body] }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    # It raises error because the default_delivery_system is
                    # wrong and delivery_options method gets nil value which
                    # is not Array
                    it 'raises error' do
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      # It raises error because it overrides the
                      # default_delivery_system and this also wrong
                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end

                context 'when none of the delivery_options and client are ' \
                        'hashes' do
                  # In this case delivey_options and client are not hashes,
                  # so the delivey_system is not important.
                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls only the new method of the client' do
                      expect(client).to receive(:new)
                      deliver
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls only the new method of the client' do
                        expect(client).to receive(:new)
                        deliver
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
