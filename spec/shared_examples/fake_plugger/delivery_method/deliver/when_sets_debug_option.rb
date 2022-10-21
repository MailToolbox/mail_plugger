# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'when_sets_debug_option' do
  context 'when sets debug option' do
    before { delivery_settings[:fake_plugger_raw_message] = false }

    let(:message) { Mail.new }

    shared_examples 'debug mode' do
      # rubocop:disable RSpec/AnyInstance
      context 'and debug mode is swiched off' do
        before { delivery_settings[:fake_plugger_debug] = false }

        it 'does NOT call show_debug_info method' do
          expect_any_instance_of(described_class)
            .not_to receive(:show_debug_info)
          deliver
        end
      end

      context 'and debug mode is swiched on' do
        it 'calls show_debug_info method' do
          expect_any_instance_of(described_class)
            .to receive(:show_debug_info)
            .and_call_original
          expect_any_instance_of(described_class).to receive(:puts)
          deliver
        end
      end
      # rubocop:enable RSpec/AnyInstance
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

        it_behaves_like 'debug mode'
      end

      context 'and NOT using MailPlugger.plug_in method' do
        context 'and sets debug value via settings' do
          subject(:deliver) do
            described_class.new(
              delivery_settings: delivery_settings
            ).deliver!(message)
          end

          it_behaves_like 'debug mode'
        end

        context 'and sets debug value via options' do
          subject(:deliver) do
            described_class.new(
              delivery_settings: delivery_settings.slice(:smtp_settings),
              debug: delivery_settings[:fake_plugger_debug]
            ).deliver!(message)
          end

          it_behaves_like 'debug mode'
        end
      end
    end

    context 'and using API' do
      context 'and using MailPlugger.plug_in method' do
        subject(:deliver) { described_class.new.deliver!(message) }

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

        it_behaves_like 'debug mode'
      end

      context 'and NOT using MailPlugger.plug_in method' do
        context 'and sets debug value via settings' do
          subject(:deliver) do
            described_class.new(
              delivery_options: delivery_options,
              client: client,
              delivery_settings: delivery_settings
            ).deliver!(message)
          end

          it_behaves_like 'debug mode'
        end

        context 'and sets debug value via options' do
          subject(:deliver) do
            described_class.new(
              delivery_options: delivery_options,
              client: client,
              debug: delivery_settings[:fake_plugger_debug]
            ).deliver!(message)
          end

          it_behaves_like 'debug mode'
        end
      end
    end
  end
end
