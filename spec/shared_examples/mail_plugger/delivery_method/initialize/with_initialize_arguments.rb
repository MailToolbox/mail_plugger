# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/initialize/' \
                      'with_initialize_arguments' do
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
