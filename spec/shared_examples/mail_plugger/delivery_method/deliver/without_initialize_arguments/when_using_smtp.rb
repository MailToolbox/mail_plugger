# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/when_using_smtp' do
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
          expect { deliver }.to raise_error(MailPlugger::Error::WrongParameter)
        end
      end

      context 'and message paramemter is a Mail::Message object' do
        shared_examples 'delivers the message' do
          before { allow(message).to receive(:deliver!) }

          it 'does NOT raise error' do
            expect { deliver }.not_to raise_error
          end

          it 'calls deliver! method of the message' do
            deliver
            expect(message).to have_received(:deliver!)
          end
        end

        context 'but message does NOT contain delivery_system' do
          let(:message) { Mail.new }

          it_behaves_like 'delivers the message'
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

              it_behaves_like 'delivers the message'
            end

            context 'and delivery_system value is symbol' do
              let(:delivery_system) { :delivery_system }

              it_behaves_like 'delivers the message'
            end
          end
        end
      end
    end
  end
end
