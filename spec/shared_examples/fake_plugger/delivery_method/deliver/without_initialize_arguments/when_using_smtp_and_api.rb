# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/when_using_smtp_and_api' do
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

            it 'returns with the message' do
              expect(deliver).to eq(message)
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
              context 'and delivery_system value is the SMTP client' do
                let(:message) do
                  Mail.new(delivery_system: smtp_delivery_system)
                end

                it 'does NOT raise error' do
                  expect { deliver }.not_to raise_error
                end

                it 'returns with the message' do
                  expect(deliver).to eq(message)
                end
              end

              context 'and delivery_system value is the API client' do
                let(:message) do
                  Mail.new(delivery_system: api_delivery_system)
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
              context 'and delivery_system value is the SMTP client' do
                let(:message) do
                  Mail.new(delivery_system: smtp_delivery_system)
                end

                it 'does NOT raise error' do
                  expect { deliver }.not_to raise_error
                end

                it 'returns with the message' do
                  expect(deliver).to eq(message)
                end
              end

              context 'and delivery_system value is the API client' do
                let(:message) do
                  Mail.new(delivery_system: api_delivery_system)
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
