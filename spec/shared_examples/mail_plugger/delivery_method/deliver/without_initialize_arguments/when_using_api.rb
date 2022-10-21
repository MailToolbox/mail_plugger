# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/when_using_api' do
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
end
