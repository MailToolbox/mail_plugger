# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailPlugger do
  describe '.configure' do
    context 'when options are missing' do
      before do
        described_class.configure do
          # Test empty block.
        end
      end

      it 'does not set default_delivery_system' do
        expect(described_class.default_delivery_system).to be_nil
      end

      it 'does not set sending_method' do
        expect(described_class.sending_method).to be_nil
      end
    end

    context 'when use unexisting options' do
      let(:configure) do
        described_class.configure do |config|
          config.unexisting = 'something'
        end
      end

      it 'raises error' do
        expect { configure }
          .to raise_error(described_class::Error::WrongConfigureOption)
      end
    end

    context 'when options are given' do
      let(:default_delivery_system) { 'default_delivery_system' }
      let(:sending_method) { 'default_delivery_system' }

      before do
        described_class.configure do |config|
          config.default_delivery_system = default_delivery_system
          config.sending_method = sending_method
        end
      end

      it 'sets default_delivery_system' do
        expect(described_class.default_delivery_system)
          .to eq(default_delivery_system)
      end

      it 'sets sending_method' do
        expect(described_class.sending_method).to eq(sending_method)
      end
    end
  end

  describe '.plug_in' do
    subject(:plug_in) do
      described_class.plug_in(delivery_system) do
        # Test empty block.
      end
    end

    before do
      stub_const('DummyApi', Class.new)
      stub_const('OtherDummyApi', Class.new)
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

    context 'when delivery system is empty string' do
      let(:delivery_system) { '' }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is a string and only has space' do
      let(:delivery_system) { ' ' }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is nil' do
      let(:delivery_system) { nil }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an empty array' do
      let(:delivery_system) { [] }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an array' do
      let(:delivery_system) { [:delivery_system] }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is an empty hash' do
      let(:delivery_system) { {} }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when delivery system is a hash' do
      let(:delivery_system) { { key: :value } }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongDeliverySystem)
      end
    end

    context 'when options are missing' do
      let(:delivery_system) { 'delivery_system' }

      before { plug_in }

      it 'does not set client' do
        expect(described_class.client).to be_nil
      end

      it 'does not set default_delivery_options' do
        expect(described_class.default_delivery_options).to be_nil
      end

      it 'does not set delivery_options' do
        expect(described_class.delivery_options).to be_nil
      end

      it 'does not set delivery_settings' do
        expect(described_class.delivery_settings).to be_nil
      end

      it 'sets delivery_systems' do
        expect(described_class.delivery_systems).to eq([delivery_system])
      end
    end

    context 'when use unexisting options' do
      subject(:plug_in) do
        described_class.plug_in(delivery_system) do |api|
          api.unexisting = 'something'
        end
      end

      let(:delivery_system) { 'delivery_system' }

      it 'raises error' do
        expect { plug_in }
          .to raise_error(described_class::Error::WrongPlugInOption)
      end
    end

    context 'when plug in a delivery system' do
      shared_examples 'setting with the right data' do |delivery_method|
        if delivery_method == 'SMTP'
          it 'does NOT set default_delivery_options' do
            expect(described_class.default_delivery_options).to be_nil
          end

          it 'does NOT set delivery_options' do
            expect(described_class.delivery_options).to be_nil
          end

          it 'does NOT set client' do
            expect(described_class.client).to be_nil
          end
        else
          it 'sets default_delivery_options' do
            expect(described_class.default_delivery_options)
              .to eq({ delivery_system => default_delivery_options })
          end

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
        let(:default_delivery_options) { nil }
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
        let(:default_delivery_options) { { tag: 'test_tag' } }
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.default_delivery_options = default_delivery_options
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
          it 'does NOT set default_delivery_options' do
            expect(described_class.default_delivery_options).to be_nil
          end

          it 'does NOT set delivery_options' do
            expect(described_class.delivery_options).to be_nil
          end

          it 'does NOT set client' do
            expect(described_class.client).to be_nil
          end

          it 'sets both delivery_settings' do
            expect(described_class.delivery_settings)
              .to eq({
                       delivery_system => delivery_settings,
                       other_delivery_system => other_delivery_settings
                     })
          end
        when 'API'
          it 'sets both default_delivery_options' do
            expect(described_class.default_delivery_options)
              .to eq({
                       delivery_system => default_delivery_options,
                       other_delivery_system => other_default_delivery_options
                     })
          end

          it 'sets both delivery_options' do
            expect(described_class.delivery_options)
              .to eq({
                       delivery_system => delivery_options,
                       other_delivery_system => other_delivery_options
                     })
          end

          it 'sets both client' do
            expect(described_class.client)
              .to eq({
                       delivery_system => client,
                       other_delivery_system => other_client
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
                       other_delivery_system => other_delivery_settings
                     })
          end
        end

        it 'sets delivery_systems' do
          expect(described_class.delivery_systems)
            .to eq([delivery_system, other_delivery_system])
        end
      end

      context 'and using more SMTPs' do
        let(:default_delivery_options) { nil }
        let(:delivery_options) { nil }
        let(:delivery_settings) { { smtp_settings: { key: :value } } }
        let(:client) { nil }
        let(:other_default_delivery_options) { nil }
        let(:other_delivery_options) { nil }
        let(:other_delivery_settings) { { smtp_settings: { key2: :value2 } } }
        let(:other_client) { nil }

        before do
          described_class.plug_in(delivery_system) do |smtp|
            smtp.delivery_settings = delivery_settings
          end

          described_class.plug_in(other_delivery_system) do |smtp|
            smtp.delivery_settings = other_delivery_settings
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:other_delivery_system) { 'other_delivery_system' }

          it_behaves_like 'setting with the right data', 'SMTP'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:other_delivery_system) { :other_delivery_system }

          it_behaves_like 'setting with the right data', 'SMTP'
        end
      end

      context 'and using more APIs' do
        let(:default_delivery_options) { { tag: 'test_tag' } }
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }
        let(:other_default_delivery_options) { { tag: 'other_test_tag' } }
        let(:other_delivery_options) do
          %i[to from subject text_part html_part]
        end
        let(:other_delivery_settings) { { key2: :value2 } }
        let(:other_client) { OtherDummyApi }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.default_delivery_options = default_delivery_options
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end

          described_class.plug_in(other_delivery_system) do |api|
            api.default_delivery_options = other_default_delivery_options
            api.delivery_options = other_delivery_options
            api.client = other_client
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:other_delivery_system) { 'other_delivery_system' }

          it_behaves_like 'setting with the right data', 'API'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:other_delivery_system) { :other_delivery_system }

          it_behaves_like 'setting with the right data', 'API'
        end
      end

      context 'and using SMTP and API' do
        let(:default_delivery_options) { { tag: 'test_tag' } }
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { { key: :value } }
        let(:client) { DummyApi }
        let(:other_default_delivery_options) { nil }
        let(:other_delivery_options) { nil }
        let(:other_delivery_settings) { { smtp_settings: { key2: :value2 } } }
        let(:other_client) { nil }

        before do
          described_class.plug_in(delivery_system) do |api|
            api.default_delivery_options = default_delivery_options
            api.delivery_options = delivery_options
            api.delivery_settings = delivery_settings
            api.client = client
          end

          described_class.plug_in(other_delivery_system) do |smtp|
            smtp.delivery_settings = other_delivery_settings
          end
        end

        context 'and delivery_systems values are string' do
          let(:delivery_system) { 'delivery_system' }
          let(:other_delivery_system) { 'other_delivery_system' }

          it_behaves_like 'setting with the right data', 'SMTP and API'
        end

        context 'and delivery_systems values are symbol' do
          let(:delivery_system) { :delivery_system }
          let(:other_delivery_system) { :other_delivery_system }

          it_behaves_like 'setting with the right data', 'SMTP and API'
        end
      end
    end
  end
end
