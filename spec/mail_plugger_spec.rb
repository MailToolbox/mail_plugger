# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailPlugger do
  describe '.plug_in' do
    before do
      stub_const('DummyApi', Class.new)
      stub_const('AnotherDummyApi', Class.new)
    end

    after do
      described_class.instance_variables.each do |variable|
        described_class.remove_instance_variable(variable)
      end
    end

    context 'when delivery system is missing' do
      it 'raises error' do
        expect { described_class.plug_in }.to raise_error(ArgumentError)
      end
    end

    # rubocop:disable Lint/EmptyBlock
    context 'when delivery system is empty string' do
      it 'raises error' do
        expect { described_class.plug_in('') {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is a string and only has space' do
      it 'raises error' do
        expect { described_class.plug_in(' ') {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is nil' do
      it 'raises error' do
        expect { described_class.plug_in(nil) {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an empty array' do
      it 'raises error' do
        expect { described_class.plug_in([]) {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an array' do
      it 'raises error' do
        expect { described_class.plug_in([:delivery_system]) {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an empty hash' do
      it 'raises error' do
        expect { described_class.plug_in({}) {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is a hash' do
      it 'raises error' do
        expect { described_class.plug_in({ key: :value }) {} }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when options are missing' do
      let(:delivery_system) { 'delivery_system' }

      before do
        described_class.plug_in(delivery_system) {}
      end

      it 'does not set client' do
        expect(described_class.client).to be nil
      end

      it 'does not set delivery_options' do
        expect(described_class.delivery_options).to be nil
      end

      it 'does not set delivery_settings' do
        expect(described_class.delivery_settings).to be nil
      end

      it 'sets delivery_systems' do
        expect(described_class.delivery_systems).to eq([delivery_system])
      end
    end
    # rubocop:enable Lint/EmptyBlock

    context 'when use unexisting options' do
      let(:delivery_system) { 'delivery_system' }
      let(:plug_in) do
        described_class.plug_in(delivery_system) do |api|
          api.unexisting = 'something'
        end
      end

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongPlugInOption)
      end
    end

    context 'when plug in a delivery system' do
      shared_examples 'setting with the right data' do |delivery_method|
        if delivery_method == 'SMTP'
          it 'does NOT set delivery_options' do
            expect(described_class.delivery_options).to be nil
          end

          it 'does NOT set client' do
            expect(described_class.client).to be nil
          end
        else
          it 'sets delivery_options' do
            expect(described_class.delivery_options)
              .to eq({ delivery_system => delivery_options })
          end

          it 'sets client' do
            expect(described_class.client).to eq({ delivery_system => client })
          end
        end

        it 'sets delivery_settings' do
          expect(described_class.delivery_settings)
            .to eq({ delivery_system => delivery_settings })
        end

        it 'sets delivery_systems' do
          expect(described_class.delivery_systems).to eq([delivery_system])
        end
      end

      context 'and using SMTP' do
        let(:delivery_options) { nil }
        let(:delivery_settings) { { smtp_settings: { key: :value } } }
        let(:client) { nil }

        before do
          described_class.plug_in(delivery_system) do |smtp|
            smtp.delivery_settings = delivery_settings
          end
        end

        context 'and delivery_system value is string' do
          let(:delivery_system) { 'delivery_system' }

          it_behaves_like 'setting with the right data', 'SMTP'
        end

        context 'and delivery_system value is symbol' do
          let(:delivery_system) { :delivery_system }

          it_behaves_like 'setting with the right data', 'SMTP'
        end
      end

      context 'and using API' do
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end
        end

        context 'and delivery_system value is string' do
          let(:delivery_system) { 'delivery_system' }

          it_behaves_like 'setting with the right data', 'API'
        end

        context 'and delivery_system value is symbol' do
          let(:delivery_system) { :delivery_system }

          it_behaves_like 'setting with the right data', 'API'
        end
      end
    end

    context 'when plug in more delivery systems' do
      shared_examples 'setting with the right data' do |delivery_method|
        case delivery_method
        when 'SMTP'
          it 'does NOT set delivery_options' do
            expect(described_class.delivery_options).to be nil
          end

          it 'does NOT set client' do
            expect(described_class.client).to be nil
          end

          it 'sets both delivery_settings' do
            expect(described_class.delivery_settings)
              .to eq({
                       delivery_system => delivery_settings,
                       another_delivery_system => another_delivery_settings
                     })
          end
        when 'API'
          it 'sets both delivery_options' do
            expect(described_class.delivery_options)
              .to eq({
                       delivery_system => delivery_options,
                       another_delivery_system => another_delivery_options
                     })
          end

          it 'sets both client' do
            expect(described_class.client)
              .to eq({
                       delivery_system => client,
                       another_delivery_system => another_client
                     })
          end

          it 'sets both delivery_settings' do
            expect(described_class.delivery_settings)
              .to eq({ delivery_system => delivery_settings })
          end
        when 'SMTP and API'
          it 'sets delivery_options for API' do
            expect(described_class.delivery_options)
              .to eq({ delivery_system => delivery_options })
          end

          it 'sets client for API' do
            expect(described_class.client).to eq({ delivery_system => client })
          end

          it 'sets both delivery_settings' do
            expect(described_class.delivery_settings)
              .to eq({
                       delivery_system => delivery_settings,
                       another_delivery_system => another_delivery_settings
                     })
          end
        end

        it 'sets delivery_systems' do
          expect(described_class.delivery_systems)
            .to eq([delivery_system, another_delivery_system])
        end
      end

      context 'and using more SMTPs' do
        let(:delivery_options) { nil }
        let(:delivery_settings) { { smtp_settings: { key: :value } } }
        let(:client) { nil }
        let(:another_delivery_options) { nil }
        let(:another_delivery_settings) { { smtp_settings: { key2: :value2 } } }
        let(:another_client) { nil }

        before do
          described_class.plug_in(delivery_system) do |smtp|
            smtp.delivery_settings = delivery_settings
          end

          described_class.plug_in(another_delivery_system) do |smtp|
            smtp.delivery_settings = another_delivery_settings
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:another_delivery_system) { 'another_delivery_system' }

          it_behaves_like 'setting with the right data', 'SMTP'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:another_delivery_system) { :another_delivery_system }

          it_behaves_like 'setting with the right data', 'SMTP'
        end
      end

      context 'and using more APIs' do
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }
        let(:another_delivery_options) do
          %i[to from subject text_part html_part]
        end
        let(:another_delivery_settings) { { key2: :value2 } }
        let(:another_client) { AnotherDummyApi }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end

          described_class.plug_in(another_delivery_system) do |api|
            api.delivery_options = another_delivery_options
            api.client = another_client
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:another_delivery_system) { 'another_delivery_system' }

          it_behaves_like 'setting with the right data', 'API'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:another_delivery_system) { :another_delivery_system }

          it_behaves_like 'setting with the right data', 'API'
        end
      end

      context 'and using SMTP and API' do
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }
        let(:another_delivery_options) { nil }
        let(:another_delivery_settings) { { smtp_settings: { key2: :value2 } } }
        let(:another_client) { nil }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end

          described_class.plug_in(another_delivery_system) do |smtp|
            smtp.delivery_settings = another_delivery_settings
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:another_delivery_system) { 'another_delivery_system' }

          it_behaves_like 'setting with the right data', 'SMTP and API'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:another_delivery_system) { :another_delivery_system }

          it_behaves_like 'setting with the right data', 'SMTP and API'
        end
      end
    end
  end
end
