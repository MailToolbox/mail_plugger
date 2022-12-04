# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/when_using_smtp_and_api' do
  context 'when using SMTP and API' do
    let(:smtp_delivery_system) { 'smtp_delivery_system' }
    let(:api_delivery_system) { 'api_delivery_system' }
    let(:delivery_settings) { { smtp_settings: { key: 'value' } } }

    shared_examples 'delivers the message' do |smtp_or_api|
      it 'does NOT raise error' do
        expect { deliver }.not_to raise_error
      end

      if smtp_or_api == 'via SMTP'
        before { allow(message).to receive(:deliver!) }

        it 'calls deliver! method of the message' do
          deliver
          expect(message).to have_received(:deliver!)
        end
      else
        before { allow(client).to receive(:new).and_return(client_object) }

        let(:client_object) { instance_double(client, deliver: true) }

        it 'calls deliver method of the client' do
          deliver
          expect(client_object).to have_received(:deliver)
        end
      end
    end

    context 'and SMTP client plugged first' do
      before do
        MailPlugger.plug_in(smtp_delivery_system) do |smtp|
          smtp.delivery_settings = delivery_settings
        end

        MailPlugger.plug_in(api_delivery_system) do |api|
          api.client = client
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

            it_behaves_like 'delivers the message', 'via SMTP'
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

                it_behaves_like 'delivers the message', 'via SMTP'
              end

              context 'and delivery_system value is the API client' do
                let(:message) do
                  Mail.new(delivery_system: api_delivery_system)
                end

                it_behaves_like 'delivers the message', 'via API'
              end
            end
          end
        end
      end
    end

    context 'and API client plugged first' do
      before do
        MailPlugger.plug_in(api_delivery_system) do |api|
          api.client = client
          api.delivery_options = delivery_options
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
          context 'but message does NOT contain delivery_system' do
            let(:message) { Mail.new }

            it_behaves_like 'delivers the message', 'via API'
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

                it_behaves_like 'delivers the message', 'via SMTP'
              end

              context 'and delivery_system value is the API client' do
                let(:message) do
                  Mail.new(delivery_system: api_delivery_system)
                end

                it_behaves_like 'delivers the message', 'via API'
              end
            end
          end
        end
      end
    end
  end
end
