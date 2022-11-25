# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'when_sets_use_mail_grabber_option' do
  context 'when sets use_mail_grabber option' do
    before do
      delivery_settings[:fake_plugger_debug] = false
      delivery_settings[:fake_plugger_raw_message] = false
    end

    let(:message) { Mail.new }

    shared_examples 'use_mail_grabber mode' do
      context 'and mail_grabber gem installed' do
        before { allow(Gem.loaded_specs).to receive(:key?).and_return(true) }

        context 'and use_mail_grabber mode is swiched off' do
          before { delivery_settings[:fake_plugger_use_mail_grabber] = false }

          it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
            expect(MailGrabber::DeliveryMethod).not_to receive(:new)
            deliver
          end
        end

        context 'and use_mail_grabber mode is swiched on' do
          it 'calls deliver! method of MailGrabber::DeliveryMethod' do
            expect(MailGrabber::DeliveryMethod)
              .to receive_message_chain(:new, :deliver!)
            deliver
          end
        end
      end

      context 'and mail_grabber gem does NOT installed' do
        before { allow(Gem.loaded_specs).to receive(:key?).and_return(false) }

        context 'and use_mail_grabber mode is swiched off' do
          before { delivery_settings[:fake_plugger_use_mail_grabber] = false }

          it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
            expect(MailGrabber::DeliveryMethod).not_to receive(:new)
            deliver
          end
        end

        context 'and use_mail_grabber mode is swiched on' do
          it 'does NOT call deliver! method of MailGrabber::DeliveryMethod' do
            expect(MailGrabber::DeliveryMethod).not_to receive(:new)
            deliver
          end
        end
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

        it_behaves_like 'use_mail_grabber mode'
      end

      context 'and NOT using MailPlugger.plug_in method' do
        context 'and sets use_mail_grabber value via settings' do
          subject(:deliver) do
            described_class.new(
              delivery_settings: delivery_settings
            ).deliver!(message)
          end

          it_behaves_like 'use_mail_grabber mode'
        end

        context 'and sets use_mail_grabber value via options' do
          subject(:deliver) do
            described_class.new(
              delivery_settings: delivery_settings.slice(:smtp_settings),
              use_mail_grabber:
                delivery_settings[:fake_plugger_use_mail_grabber]
            ).deliver!(message)
          end

          it_behaves_like 'use_mail_grabber mode'
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

        it_behaves_like 'use_mail_grabber mode'
      end

      context 'and NOT using MailPlugger.plug_in method' do
        context 'and sets use_mail_grabber value via settings' do
          subject(:deliver) do
            described_class.new(
              client: client,
              delivery_options: delivery_options,
              delivery_settings: delivery_settings
            ).deliver!(message)
          end

          it_behaves_like 'use_mail_grabber mode'
        end

        context 'and sets use_mail_grabber value via options' do
          subject(:deliver) do
            described_class.new(
              client: client,
              delivery_options: delivery_options,
              use_mail_grabber:
                delivery_settings[:fake_plugger_use_mail_grabber]
            ).deliver!(message)
          end

          it_behaves_like 'use_mail_grabber mode'
        end
      end
    end
  end
end
