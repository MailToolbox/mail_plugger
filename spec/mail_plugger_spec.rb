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

    context 'when api options are missing' do
      let(:delivery_system) { 'dummy_api' }

      before do
        described_class.plug_in(delivery_system) {}
      end

      it 'does not set delivery_options' do
        expect(described_class.delivery_options).to be nil
      end

      it 'does not set client' do
        expect(described_class.client).to be nil
      end
    end
    # rubocop:enable Lint/EmptyBlock

    context 'when use unexisting options' do
      let(:delivery_system) { 'dummy_api' }
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
      let(:delivery_system) { 'dummy_api' }
      let(:delivery_options) { %i[to from subject body] }

      before do
        described_class.plug_in(delivery_system) do |api|
          api.delivery_options = delivery_options
          api.client = DummyApi
        end
      end

      it 'sets delivery_options' do
        expect(described_class.delivery_options)
          .to eq({ delivery_system => delivery_options })
      end

      it 'sets client' do
        expect(described_class.client).to eq({ delivery_system => DummyApi })
      end
    end

    context 'when plug in more delivery systems' do
      let(:delivery_system) { 'dummy_api' }
      let(:delivery_options) { %i[to from subject body] }
      let(:another_delivery_system) { 'another_dummy_api' }
      let(:another_delivery_options) { %i[to from subject text_part html_part] }

      before do
        described_class.plug_in(delivery_system) do |api|
          api.delivery_options = delivery_options
          api.client = DummyApi
        end

        described_class.plug_in(another_delivery_system) do |api|
          api.delivery_options = another_delivery_options
          api.client = AnotherDummyApi
        end
      end

      it 'sets delivery_options' do
        expect(described_class.delivery_options)
          .to eq({
                   delivery_system => delivery_options,
                   another_delivery_system => another_delivery_options
                 })
      end

      it 'sets client' do
        expect(described_class.client)
          .to eq({
                   delivery_system => DummyApi,
                   another_delivery_system => AnotherDummyApi
                 })
      end
    end
  end
end
