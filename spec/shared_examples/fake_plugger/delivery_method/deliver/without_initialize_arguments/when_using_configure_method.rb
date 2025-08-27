# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'without_initialize_arguments/' \
                      'when_using_configure_method' do
  context 'when using MailPlugger.configure method' do
    subject(:deliver) { described_class.new.deliver!(message) }

    let(:smtp_delivery_system) { 'smtp_delivery_system' }
    let(:api_delivery_system) { 'api_delivery_system' }
    let(:delivery_settings) { { smtp_settings: { key: 'value' } } }
    let(:client_object) { instance_double(client, deliver: true) }

    before do
      MailPlugger.plug_in(smtp_delivery_system) do |smtp|
        smtp.delivery_settings = delivery_settings
      end

      MailPlugger.plug_in(api_delivery_system) do |api|
        api.client = client
        api.delivery_options = delivery_options
      end

      MailPlugger.configure do |config|
        config.default_delivery_system = default_delivery_system
        config.sending_method = sending_method
      end

      allow(message).to receive(:deliver!)
      allow(client).to receive(:new).and_return(client_object)
    end

    shared_examples 'the message does NOT contain ' \
                    'delivery_system' do |using_protocol|
      let(:message) { Mail.new }

      it 'does NOT raise error' do
        expect { deliver }.not_to raise_error
      end

      if using_protocol.match?('SMTP')
        it 'returns with the message' do
          expect(deliver).to eq(message)
        end
      else
        it 'calls only the new method of the client' do
          deliver
          expect(client).to have_received(:new)
          expect(client_object).not_to have_received(:deliver)
        end
      end
    end

    shared_examples 'the message contains delivery_system' do
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

          it 'returns with the message' do
            expect(deliver).to eq(message)
            expect(message).not_to have_received(:deliver!)
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
            deliver
            expect(client).to have_received(:new)
            expect(client_object).not_to have_received(:deliver)
          end
        end
      end
    end

    context 'when default_delivery_system is configured' do
      context 'and default_delivery_system is the smtp_delivery_system' do
        let(:default_delivery_system) { smtp_delivery_system }

        it_behaves_like 'the message does NOT contain delivery_system',
                        'and using SMTP'

        it_behaves_like 'the message contains delivery_system'
      end

      context 'and default_delivery_system is the api_delivery_system' do
        let(:default_delivery_system) { api_delivery_system }

        it_behaves_like 'the message does NOT contain delivery_system',
                        'and using API'

        it_behaves_like 'the message contains delivery_system'
      end
    end

    context 'when sending_method is configured' do
      context 'and sending_method is default_delivery_system' do
        let(:sending_method) { :default_delivery_system }

        context 'but default_delivery_system is NOT configred' do
          let(:default_delivery_system) { nil }

          it_behaves_like 'the message does NOT contain delivery_system',
                          'and using SMTP'

          it_behaves_like 'the message contains delivery_system'
        end

        context 'and default_delivery_system is configred' do
          context 'and default_delivery_system is the smtp_delivery_system' do
            let(:default_delivery_system) { smtp_delivery_system }

            it_behaves_like 'the message does NOT contain delivery_system',
                            'and using SMTP'

            it_behaves_like 'the message contains delivery_system'
          end

          context 'and default_delivery_system is the api_delivery_system' do
            let(:default_delivery_system) { api_delivery_system }

            it_behaves_like 'the message does NOT contain delivery_system',
                            'and using API'

            it_behaves_like 'the message contains delivery_system'
          end
        end
      end

      context 'and sending_method is plugged_in_first' do
        let(:sending_method) { :plugged_in_first }

        it_behaves_like 'the message does NOT contain delivery_system',
                        'and the first plugged-in method is SMTP'

        it_behaves_like 'the message contains delivery_system'
      end

      context 'and sending_method is random' do
        let(:sending_method) { :random }

        it_behaves_like 'the message does NOT contain delivery_system',
                        'and choosing SMTP or API' do
          # we have 2 delivery method, so rand(2) will be 0
          before { srand(4) }
        end

        it_behaves_like 'the message contains delivery_system'
      end

      context 'and sending_method is round_robin' do
        let(:sending_method) { :round_robin }

        context 'and message does NOT contain delivery_system' do
          subject(:deliver) do
            proc { described_class.new.deliver!(message) }
          end

          let(:message) { Mail.new }

          it 'returns with the message or calls only the new method of the ' \
             'client' do
            expect(deliver.call).to eq(message)
            expect(message).not_to have_received(:deliver!)
            deliver.call
            expect(client).to have_received(:new)
            expect(client_object).not_to have_received(:deliver)
          end
        end

        it_behaves_like 'the message contains delivery_system'
      end
    end
  end
end
