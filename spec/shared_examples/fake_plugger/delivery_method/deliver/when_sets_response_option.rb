# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'when_sets_response_option' do
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
      let(:client_object) { instance_double(client, deliver: true) }

      before do
        allow(client).to receive(:new).and_return(client_object)
        allow(message).to receive(:delivery_method)
      end

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
          deliver
          expect(client).not_to have_received(:new)
        end
      end

      context 'and does NOT set the response value' do
        before { delivery_settings[:fake_plugger_response] = nil }

        if delivery_method == 'SMTP'
          it 'calls the delivery_method method of the message' do
            deliver
            expect(message).to have_received(:delivery_method)
          end
        else
          it 'calls only the new method of the client' do
            deliver
            expect(client).to have_received(:new)
            expect(client_object).not_to have_received(:deliver)
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
            api.client = client
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
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
              client: client,
              delivery_options: delivery_options,
              delivery_settings: delivery_settings
            ).deliver!(message)
          end

          it_behaves_like 'fake response', 'and using settings', 'API'
        end

        context 'and sets response value via options' do
          subject(:deliver) do
            described_class.new(
              client: client,
              delivery_options: delivery_options,
              response: delivery_settings[:fake_plugger_response]
            ).deliver!(message)
          end

          it_behaves_like 'fake response', 'and NOT using settings', 'API'
        end
      end
    end

    context 'when using SMTP and API' do
      context 'and using MailPlugger.plug_in method' do
        subject(:deliver) { described_class.new.deliver!(message) }

        before do
          MailPlugger.plug_in(api_delivery_system) do |api|
            api.client = client
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
          end

          MailPlugger.plug_in(smtp_delivery_system) do |smtp|
            smtp.delivery_settings = {
              smtp_settings: { key: 'value' },
              fake_plugger_response: 'SMTP OK'
            }
          end
        end

        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        let(:smtp_delivery_system) { 'smtp_delivery_system' }
        let(:api_delivery_system) { 'api_delivery_system' }

        context 'and testing SMTP response' do
          before { message[:delivery_system] = smtp_delivery_system }

          it 'response with right value' do
            expect(deliver).to eq('SMTP OK')
          end
        end

        context 'and testing API response' do
          before { message[:delivery_system] = api_delivery_system }

          it 'response with right value' do
            expect(deliver).to eq(delivery_settings[:fake_plugger_response])
          end
        end
      end
    end
  end
end
