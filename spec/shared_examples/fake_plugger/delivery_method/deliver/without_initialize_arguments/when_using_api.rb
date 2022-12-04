# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/when_using_api' do
  context 'when using API' do
    before do
      MailPlugger.plug_in(delivery_system) do |api|
        api.client = client
        api.default_delivery_options = default_delivery_options
        api.delivery_options = delivery_options
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

      shared_examples 'fake delivery of the message' do
        let(:client_object) { instance_double(client, deliver: true) }

        before { allow(client).to receive(:new).and_return(client_object) }

        it 'does NOT raise error' do
          expect { deliver }.not_to raise_error
        end

        it 'calls only the new method of the client' do
          deliver
          expect(client).to have_received(:new)
          expect(client_object).not_to have_received(:deliver)
        end
      end

      context 'and message paramemter does NOT a Mail::Message object' do
        let(:message) { nil }

        it 'raises error' do
          expect { deliver }.to raise_error(MailPlugger::Error::WrongParameter)
        end
      end

      context 'and message paramemter is a Mail::Message object' do
        context 'but message does NOT contain delivery_system' do
          let(:message) { Mail.new }

          it_behaves_like 'fake delivery of the message'
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

              it_behaves_like 'fake delivery of the message'
            end

            context 'and delivery_system value is symbol' do
              let(:delivery_system) { :delivery_system }

              it_behaves_like 'fake delivery of the message'
            end
          end
        end

        context 'when plug_in method has client' do
          let(:message) { Mail.new }

          context 'but client does NOT a class' do
            let(:client) { 'not_class' }

            it 'raises error' do
              expect { deliver }
                .to raise_error(MailPlugger::Error::WrongApiClient)
            end
          end

          context 'but client does NOT have a deliver method' do
            let(:client) { Class.new }

            it 'raises error' do
              expect { deliver }
                .to raise_error(MailPlugger::Error::WrongApiClient)
            end
          end

          context 'and client is a class with deliver method' do
            let(:client) { DummyApi }

            it_behaves_like 'fake delivery of the message'
          end
        end

        context 'when plug_in method has default_delivery_options' do
          context 'but default_delivery_options does NOT a hash' do
            let(:default_delivery_options) { 'not_hash' }
            let(:message) { Mail.new }

            it 'raises error' do
              expect { deliver }
                .to raise_error(MailPlugger::Error::WrongDefaultDeliveryOptions)
            end
          end

          context 'and default_delivery_options is a hash' do
            let(:default_delivery_options) { { tag: 'test_tag' } }

            before do
              allow(client).to receive(:new).and_call_original
              deliver
            end

            context 'and message does NOT contain extra delivery options' do
              let(:message) { Mail.new }

              it 'calls deliver method of the client with the option, ' \
                 'defined in the default_delivery_options' do
                expect(client).to have_received(:new)
                  .with(hash_including(default_delivery_options))
              end
            end

            context 'and message contains extra delivery options' do
              let(:message) { Mail.new(tag: 'defined_in_mail') }

              context 'and delivery_options does NOT contain this option' do
                it 'calls deliver method of the client with the option, ' \
                   'defined in the default_delivery_options' do
                  expect(client).to have_received(:new)
                    .with(hash_including(default_delivery_options))
                end
              end

              context 'and delivery_options contains this option' do
                let(:delivery_options) { %i[to from subject body tag] }

                it 'calls deliver method of the client with the option, ' \
                   'defined in the message' do
                  expect(client).to have_received(:new)
                    .with(hash_including(tag: 'defined_in_mail'))
                end
              end
            end
          end
        end

        context 'when plug_in method has delivery_options' do
          let(:default_delivery_options) { nil }

          context 'but delivery_options does NOT an array' do
            let(:delivery_options) { 'not_array' }
            let(:message) { Mail.new }

            it 'raises error' do
              expect { deliver }
                .to raise_error(MailPlugger::Error::WrongDeliveryOptions)
            end
          end

          context 'and delivery_options is a array' do
            let(:delivery_options) { %i[to] }

            before do
              allow(client).to receive(:new).and_call_original
              deliver
            end

            context 'and message does NOT contain extra delivery options' do
              let(:message) { Mail.new }

              it 'calls deliver method of the client with the option, ' \
                 'defined in the delivery_options with nil value' do
                expect(client).to have_received(:new)
                  .with(hash_including(to: nil))
              end
            end

            context 'and message contains extra delivery options' do
              let(:message) { Mail.new(to: 'test@example.com') }

              it 'calls deliver method of the client with the option, ' \
                 'defined in the message' do
                expect(client).to have_received(:new)
                  .with(hash_including(to: ['test@example.com']))
              end
            end
          end
        end
      end
    end
  end
end
