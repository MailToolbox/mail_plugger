# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/initialize/' \
                      'without_initialize_arguments' do
  context 'without initialize arguments' do
    subject(:init_method) { described_class.new }

    context 'when using MailPlugger.configure method' do
      before do
        MailPlugger.configure do |config|
          config.default_delivery_system = default_delivery_system
          config.sending_method = sending_method
          config.sending_options = sending_options
        end
      end

      after do
        MailPlugger.instance_variables.each do |variable|
          MailPlugger.remove_instance_variable(variable)
        end
      end

      it 'sets passed_delivery_system with expected value' do
        expect(init_method.instance_variable_get(:@passed_delivery_system))
          .to eq(default_delivery_system)
      end

      it 'sets sending_method with expected value' do
        expect(init_method.instance_variable_get(:@sending_method))
          .to eq(sending_method)
      end

      it 'sets sending_options with expected value' do
        expect(init_method.instance_variable_get(:@sending_options))
          .to eq(sending_options)
      end

      it 'sets default_delivery_system with expected value' do
        expect(init_method.instance_variable_get(:@default_delivery_system))
          .to eq(default_delivery_system)
      end
    end

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
end
