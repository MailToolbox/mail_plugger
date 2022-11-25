# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/initialize/' \
                      'with_initialize_arguments' do
  context 'with initialize arguments' do
    shared_examples 'arguments' do |use_settings_or_options|
      it 'sets client with given value' do
        expect(init_method.instance_variable_get(:@client)).to eq(client)
      end

      it 'sets delivery_options with given value' do
        expect(init_method.instance_variable_get(:@delivery_options))
          .to eq(delivery_options)
      end

      it 'sets delivery_settings with given value' do
        expect(init_method.instance_variable_get(:@delivery_settings))
          .to eq(delivery_settings)
      end

      it 'sets default_delivery_system with given value' do
        expect(init_method.instance_variable_get(:@default_delivery_system))
          .to eq(delivery_system)
      end

      it 'sets message with nil' do
        expect(init_method.instance_variable_get(:@message)).to be_nil
      end

      if use_settings_or_options == 'using settings'
        it 'does NOT set debug yet' do
          expect(init_method.instance_variable_get(:@debug)).to be_nil
        end

        it 'does NOT set raw_message yet' do
          expect(init_method.instance_variable_get(:@raw_message)).to be_nil
        end

        it 'does NOT set response yet' do
          expect(init_method.instance_variable_get(:@response)).to be_nil
        end

        it 'does NOT set use_mail_grabber yet' do
          expect(init_method.instance_variable_get(:@use_mail_grabber))
            .to be_nil
        end
      else
        it 'sets debug with given value' do
          expect(init_method.instance_variable_get(:@debug))
            .to eq(delivery_settings[:fake_plugger_debug])
        end

        it 'sets raw_message with given value' do
          expect(init_method.instance_variable_get(:@raw_message))
            .to eq(delivery_settings[:fake_plugger_raw_message])
        end

        it 'sets response with given value' do
          expect(init_method.instance_variable_get(:@response))
            .to eq(delivery_settings[:fake_plugger_response])
        end

        it 'sets use_mail_grabber with expected value' do
          expect(init_method.instance_variable_get(:@use_mail_grabber))
            .to eq(delivery_settings[:fake_plugger_use_mail_grabber])
        end
      end
    end

    context 'and sets debug value via settings' do
      subject(:init_method) do
        described_class.new(
          client: client,
          delivery_options: delivery_options,
          default_delivery_system: delivery_system,
          delivery_settings: delivery_settings
        )
      end

      context 'when using MailPlugger.plug_in method' do
        before do
          MailPlugger.plug_in('different_api') do |api|
            api.client = 'different client'
            api.delivery_options = 'different options'
            api.delivery_settings = 'different settings'
          end
        end

        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        it_behaves_like 'arguments', 'using settings'
      end

      context 'when NOT using MailPlugger.plug_in method' do
        it_behaves_like 'arguments', 'using settings'
      end
    end

    context 'and sets debug value via options' do
      subject(:init_method) do
        described_class.new(
          client: client,
          delivery_options: delivery_options,
          delivery_settings: delivery_settings,
          default_delivery_system: delivery_system,
          debug: delivery_settings[:fake_plugger_debug],
          raw_message: delivery_settings[:fake_plugger_raw_message],
          response: delivery_settings[:fake_plugger_response],
          use_mail_grabber: delivery_settings[:fake_plugger_use_mail_grabber]
        )
      end

      context 'when using MailPlugger.plug_in method' do
        before do
          MailPlugger.plug_in('different_api') do |api|
            api.client = 'different client'
            api.delivery_options = 'different options'
            api.delivery_settings = 'different settings'
          end
        end

        after do
          MailPlugger.instance_variables.each do |variable|
            MailPlugger.remove_instance_variable(variable)
          end
        end

        it_behaves_like 'arguments', 'using options'
      end

      context 'when NOT using MailPlugger.plug_in method' do
        it_behaves_like 'arguments', 'using options'
      end
    end
  end
end
