# frozen_string_literal: true

require 'spec_helper'

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
  let(:delivery_system) { 'delivery_system' }
  let(:delivery_options) { %i[to from subject body] }
  let(:delivery_settings) { { key: :value } }
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
          expect(init_method.instance_variable_get(:@delivery_options))
            .to eq({ delivery_system => delivery_options })
        end

        it 'sets client with expected value' do
          expect(init_method.instance_variable_get(:@client))
            .to eq({ delivery_system => DummyApi })
        end

        it 'sets default_delivery_system with expected value' do
          expect(init_method.instance_variable_get(:@default_delivery_system))
            .to eq(delivery_system)
        end

        it 'sets delivery_settings with expected value' do
          expect(init_method.instance_variable_get(:@delivery_settings))
            .to eq({ delivery_system => delivery_settings })
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get(:@message)).to be_nil
        end
      end

      context 'when NOT using MailPlugger.plug_in method' do
        it 'does NOT set delivery_options' do
          expect(init_method.instance_variable_get(:@delivery_options))
            .to be_nil
        end

        it 'does NOT set client' do
          expect(init_method.instance_variable_get(:@client)).to be_nil
        end

        it 'does NOT set default_delivery_system' do
          expect(init_method.instance_variable_get(:@default_delivery_system))
            .to be_nil
        end

        it 'does NOT set delivery_settings' do
          expect(init_method.instance_variable_get(:@delivery_settings))
            .to be_nil
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get(:@message)).to be_nil
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
          expect(init_method.instance_variable_get(:@delivery_options))
            .to eq(delivery_options)
        end

        it 'sets client with given value' do
          expect(init_method.instance_variable_get(:@client)).to eq(client)
        end

        it 'sets default_delivery_system with given value' do
          expect(init_method.instance_variable_get(:@default_delivery_system))
            .to eq(delivery_system)
        end

        it 'sets delivery_settings with given value' do
          expect(init_method.instance_variable_get(:@delivery_settings))
            .to eq(delivery_settings)
        end

        it 'sets message with nil' do
          expect(init_method.instance_variable_get(:@message)).to be_nil
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
    context 'without initialize arguments' do
      context 'when using MailPlugger.plug_in method' do
        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        context 'when using SMTP' do
          before do
            MailPlugger.plug_in(delivery_system) do |smtp|
              smtp.delivery_settings = { smtp_settings: { key: 'value' } }
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

            context 'and message paramemter does NOT a Mail::Message object' do
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

                it 'calls deliver! method of the message' do
                  expect(message).to receive(:deliver!)
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
                    let(:delivery_system) { 'delivery_system' }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver! method of the message' do
                      expect(message).to receive(:deliver!)
                      deliver
                    end
                  end

                  context 'and delivery_system value is symbol' do
                    let(:delivery_system) { :delivery_system }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver! method of the message' do
                      expect(message).to receive(:deliver!)
                      deliver
                    end
                  end
                end
              end
            end
          end
        end

        context 'when using API' do
          before do
            MailPlugger.plug_in(delivery_system) do |api|
              api.delivery_options = delivery_options
              api.client = client
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

                it 'does NOT raise error' do
                  expect { deliver }.not_to raise_error
                end

                it 'calls deliver method of the client' do
                  expect(client).to receive_message_chain(:new, :deliver)
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
                    let(:delivery_system) { 'delivery_system' }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end

                  context 'and delivery_system value is symbol' do
                    let(:delivery_system) { :delivery_system }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end
            end
          end
        end

        context 'when using SMTP and API' do
          let(:smtp_delivery_system) { 'smtp_delivery_system' }
          let(:api_delivery_system) { 'api_delivery_system' }
          let(:delivery_settings) { { smtp_settings: { key: 'value' } } }

          context 'and SMTP client plugged first' do
            before do
              MailPlugger.plug_in(smtp_delivery_system) do |smtp|
                smtp.delivery_settings = delivery_settings
              end

              MailPlugger.plug_in(api_delivery_system) do |api|
                api.delivery_options = delivery_options
                api.client = client
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

                  it 'calls deliver! method of the message' do
                    expect(message).to receive(:deliver!)
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
                    context 'and delivery_system value is the SMTP client' do
                      let(:message) do
                        Mail.new(delivery_system: smtp_delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
                        deliver
                      end
                    end

                    context 'and delivery_system value is the API client' do
                      let(:message) do
                        Mail.new(delivery_system: api_delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver method of the client' do
                        expect(client).to receive_message_chain(:new, :deliver)
                        deliver
                      end
                    end
                  end
                end
              end
            end
          end

          context 'and API client plugged first' do
            before do
              MailPlugger.plug_in(api_delivery_system) do |api|
                api.delivery_options = delivery_options
                api.client = client
              end

              MailPlugger.plug_in(smtp_delivery_system) do |smtp|
                smtp.delivery_settings = delivery_settings
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

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
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
                    context 'and delivery_system value is the SMTP client' do
                      let(:message) do
                        Mail.new(delivery_system: smtp_delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
                        deliver
                      end
                    end

                    context 'and delivery_system value is the API client' do
                      let(:message) do
                        Mail.new(delivery_system: api_delivery_system)
                      end

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver method of the client' do
                        expect(client).to receive_message_chain(:new, :deliver)
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

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'raises error' do
                          expect { deliver }
                            .to raise_error(MailPlugger::Error::WrongApiClient)
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

                      context 'but message does NOT contain delivery_system' do
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
                      { smtp_settings: { key: 'value' }, return_response: true }
                    end

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
                        deliver
                      end
                    end

                    context 'and message contains delivery_system' do
                      # In this case delivey_settings does not contain
                      # delivery_system, so the delivey_system is not important.
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
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

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
                          deliver
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

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'raises error' do
                          expect { deliver }
                            .to raise_error(MailPlugger::Error::WrongApiClient)
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

                      context 'but message does NOT contain delivery_system' do
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

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
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

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
                          deliver
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

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'raises error' do
                          expect { deliver }
                            .to raise_error(MailPlugger::Error::WrongApiClient)
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

                      context 'but message does NOT contain delivery_system' do
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
                      { smtp_settings: { key: 'value' }, return_response: true }
                    end

                    context 'but message does NOT contain delivery_system' do
                      let(:message) { Mail.new }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
                        deliver
                      end
                    end

                    context 'and message contains delivery_system' do
                      # In this case delivey_settings does not contain
                      # delivery_system, so the delivey_system is not important.
                      context 'but the given delivery_system does NOT exist' do
                        let(:message) { Mail.new(delivery_system: 'key') }

                        it 'does NOT raise error' do
                          expect { deliver }.not_to raise_error
                        end

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
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

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
                          deliver
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

                      context 'but message does NOT contain delivery_system' do
                        let(:message) { Mail.new }

                        it 'raises error' do
                          expect { deliver }
                            .to raise_error(MailPlugger::Error::WrongApiClient)
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

                      context 'but message does NOT contain delivery_system' do
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

                      it 'calls deliver! method of the message' do
                        expect(message).to receive(:deliver!)
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

                        it 'calls deliver! method of the message' do
                          expect(message).to receive(:deliver!)
                          deliver
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

                  it 'calls deliver method of the client' do
                    expect(DummyApi).to receive_message_chain(:new, :deliver)
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

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(DummyApi).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end

              context 'when one of the delivery_options and client is a hash' do
                let(:delivery_options) do
                  { delivery_system => %i[to from subject body] }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
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

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end

              context 'when none of the delivery_options and client are ' \
                      'hashes' do
                # In this case delivey_options and client are not hashes, so the
                # delivey_system is not important.
                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
                    deliver
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
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

                  # It won't raise error because the default_delivery_system is
                  # defined
                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(DummyApi).to receive_message_chain(:new, :deliver)
                    deliver
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    # It raises error because it overrides the
                    # default_delivery_system
                    it 'raises error' do
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    context 'and delivery_system value is string' do
                      let(:delivery_system) { 'delivery_system' }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver method of the client' do
                        expect(DummyApi)
                          .to receive_message_chain(:new, :deliver)
                        deliver
                      end
                    end

                    context 'and delivery_system value is symbol' do
                      let(:delivery_system) { :delivery_system }

                      it 'does NOT raise error' do
                        expect { deliver }.not_to raise_error
                      end

                      it 'calls deliver method of the client' do
                        expect(DummyApi)
                          .to receive_message_chain(:new, :deliver)
                        deliver
                      end
                    end
                  end
                end
              end

              context 'when one of the delivery_options and client is a hash' do
                let(:delivery_options) do
                  { delivery_system => %i[to from subject body] }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  # It won't raise error because the default_delivery_system is
                  # defined
                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
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

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end

              context 'when none of the delivery_options and client are ' \
                      'hashes' do
                # In this case delivey_options and client are not hashes, so the
                # delivey_system is not important.
                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
                    deliver
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end
            end

            context 'and default_delivery_system is defined but with a wrong ' \
                    'value' do
              let(:default_delivery_system) { 'wrong_value' }

              context 'when both delivery_options and client are hashes' do
                let(:delivery_options) do
                  { delivery_system => %i[to from subject body] }
                end
                let(:client) { { delivery_system => DummyApi } }

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  # It raises error because the default_delivery_system is wrong
                  # and delivery_options method gets nil value which is not
                  # Array
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
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(DummyApi).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end

              context 'when one of the delivery_options and client is a hash' do
                let(:delivery_options) do
                  { delivery_system => %i[to from subject body] }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  # It raises error because the default_delivery_system is wrong
                  # and delivery_options method gets nil value which is not
                  # Array
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
                      expect { deliver }
                        .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end
                end
              end

              context 'when none of the delivery_options and client are ' \
                      'hashes' do
                # In this case delivey_options and client are not hashes, so the
                # delivey_system is not important.
                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'calls deliver method of the client' do
                    expect(client).to receive_message_chain(:new, :deliver)
                    deliver
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
                      deliver
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'calls deliver method of the client' do
                      expect(client).to receive_message_chain(:new, :deliver)
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
