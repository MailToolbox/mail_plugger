# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MailPlugger::MailHelper do
  before do
    test_class =
      Class.new do
        include MailPlugger::MailHelper

        def initialize(options = {})
          @client = options[:client]
          @delivery_options = options[:delivery_options]
          @delivery_settings = options[:delivery_settings]
          @passed_default_delivery_system =
            options[:passed_default_delivery_system]
          @default_delivery_options = options[:default_delivery_options]
          @delivery_systems = options[:delivery_systems]
          @rotatable_delivery_systems = options[:rotatable_delivery_systems]
          @sending_method = options[:sending_method]
          @default_delivery_system = options[:default_delivery_system]
          @message = options[:message]
        end
      end
    stub_const('TestClass', test_class)
    stub_const('DummyApi', Class.new { def deliver; end })
    stub_const('OtherDummyApi', Class.new { def deliver; end })
  end

  describe '#check_version_of' do
    subject(:check_version) { TestClass.new.check_version_of('mail', version) }

    before do
      allow(Gem.loaded_specs['mail']).to receive(:version)
        .and_return(current_version)
    end

    context 'when the gem version should greater than required' do
      let(:version) { '> 2.7.0' }

      context 'and the current version less than or equal to the required' do
        let(:current_version) { Gem::Version.new('2.7.0') }

        it 'returns with false' do
          expect(check_version).to be false
        end
      end

      context 'and the current version greater than the required' do
        let(:current_version) { Gem::Version.new('2.7.1') }

        it 'returns with true' do
          expect(check_version).to be true
        end
      end
    end

    context 'when the mail gem version should equal to the required' do
      let(:version) { '= 2.7.0' }

      context 'and the current version less than the required' do
        let(:current_version) { Gem::Version.new('2.6.9') }

        it 'returns with false' do
          expect(check_version).to be false
        end
      end

      context 'and the current version greater than the required' do
        let(:current_version) { Gem::Version.new('2.7.1') }

        it 'returns with false' do
          expect(check_version).to be false
        end
      end

      context 'and the current version equal to the required' do
        let(:current_version) { Gem::Version.new('2.7.0') }

        it 'returns with true' do
          expect(check_version).to be true
        end
      end
    end

    context 'when the mail gem version should less than the required' do
      let(:version) { '< 2.7.0' }

      context 'and the current version less than the required' do
        let(:current_version) { Gem::Version.new('2.6.9') }

        it 'returns with true' do
          expect(check_version).to be true
        end
      end

      context 'and the current version greater than or equal to the required' do
        let(:current_version) { Gem::Version.new('2.7.0') }

        it 'returns with false' do
          expect(check_version).to be false
        end
      end
    end
  end

  describe '#client' do
    subject(:client) do
      TestClass.new(client: dummy_client, message: message).client
    end

    let(:message) { Mail.new(delivery_system: 'delivery_system') }

    context 'when client does NOT a class' do
      let(:dummy_client) { 'DummyApi' }

      it 'raises error' do
        expect { client }.to raise_error(MailPlugger::Error::WrongApiClient)
      end
    end

    context 'when client class does NOT have a deliver method' do
      let(:dummy_client) { Class.new }

      it 'raises error' do
        expect { client }.to raise_error(MailPlugger::Error::WrongApiClient)
      end
    end

    context 'when client does NOT a hash' do
      let(:dummy_client) { DummyApi }

      it 'returns with the given class' do
        expect(client).to eq(dummy_client)
      end
    end

    context 'when client is a hash' do
      let(:dummy_client) do
        {
          'delivery_system' => DummyApi,
          'other_delivery_system' => OtherDummyApi
        }
      end

      it 'returns with the right class from the hash' do
        expect(client).to eq(dummy_client['delivery_system'])
      end
    end
  end

  describe '#delivery_data' do
    subject(:delivery_data) do
      TestClass
        .new(
          delivery_options: delivery_options,
          default_delivery_options: default_delivery_options,
          message: message
        )
        .delivery_data
    end

    let(:default_delivery_options) { nil }

    context 'when mail does NOT multipart' do
      let(:delivery_options) { %i[from to subject body] }
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

      it 'returns back with the right data' do
        expect(delivery_data).to eq(expected_hash)
      end
    end

    context 'when mail is multipart' do
      context 'and does NOT has attachments' do
        let(:delivery_options) { %i[from to subject text_part html_part] }
        let(:message) do
          Mail.new(
            from: 'from@example.com',
            to: 'to@example.com',
            subject: 'This is the message subject'
          ) do
            text_part do
              body 'This is plain text'
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body '<h1>This is HTML</h1>'
            end
          end
        end
        let(:expected_hash) do
          {
            'from' => ['from@example.com'],
            'to' => ['to@example.com'],
            'subject' => 'This is the message subject',
            'text_part' => 'This is plain text',
            'html_part' => '<h1>This is HTML</h1>'
          }
        end

        it 'returns back with the right data' do
          expect(delivery_data).to eq(expected_hash)
        end

        it 'returns with indifferent hash' do
          expect(delivery_data[:from]).to eq(['from@example.com'])
          expect(delivery_data['from']).to eq(['from@example.com'])
        end
      end

      context 'and has attachments' do
        let(:delivery_options) do
          %i[from to subject text_part html_part attachments]
        end
        let(:message) do
          message = Mail.new(
            from: 'from@example.com',
            to: 'to@example.com',
            subject: 'This is the message subject'
          ) do
            text_part do
              body 'This is plain text'
            end

            html_part do
              content_type 'text/html; charset=UTF-8'
              body '<h1>This is HTML</h1>'
            end

            add_file File.expand_path('../LICENSE.txt', File.dirname(__dir__))
          end
          message.attachments.inline['README.md'] =
            File.read(File.expand_path('../README.md', File.dirname(__dir__)))

          message
        end
        let(:expected_hash) do
          {
            'from' => ['from@example.com'],
            'to' => ['to@example.com'],
            'subject' => 'This is the message subject',
            'text_part' => 'This is plain text',
            'html_part' => '<h1>This is HTML</h1>',
            'attachments' => [
              {
                'filename' => 'LICENSE.txt',
                'type' => 'text/plain',
                'content' => Base64.encode64(
                  File.read(
                    File.expand_path('../LICENSE.txt', File.dirname(__dir__))
                  )
                )
              },
              {
                'cid' => message.attachments.inline['README.md'].cid,
                'filename' => 'README.md',
                'type' => 'text/markdown',
                'content' => Base64.encode64(
                  File.read(
                    File.expand_path('../README.md', File.dirname(__dir__))
                  )
                )
              }
            ]
          }
        end

        it 'returns back with the right data' do
          expect(delivery_data).to eq(expected_hash)
        end

        it 'returns with indifferent hash' do
          expect(delivery_data[:attachments].first[:filename])
            .to eq('LICENSE.txt')
          expect(delivery_data['attachments'].first['filename'])
            .to eq('LICENSE.txt')
        end
      end
    end

    context 'when mail has extra options' do
      let(:delivery_options) do
        %i[from to subject body string boolean array hash message_obj]
      end
      let(:message) do
        Mail.new(
          from: 'from@example.com',
          to: 'to@example.com',
          subject: 'This is the message subject',
          body: 'This is the message body',
          string: 'This is the string',
          boolean: true,
          array: ['This', 'is', 'the array'],
          hash: { this: 'is the hash' }
        )
      end
      let(:expected_hash) do
        {
          'from' => ['from@example.com'],
          'to' => ['to@example.com'],
          'subject' => 'This is the message subject',
          'body' => 'This is the message body',
          'string' => 'This is the string',
          'boolean' => true,
          'array' => ['This', 'is', 'the array'],
          'hash' => { 'this' => 'is the hash' },
          'message_obj' => message
        }
      end

      it 'returns back with the right data' do
        expect(delivery_data).to eq(expected_hash)
      end

      it 'returns with indifferent hash' do
        expect(delivery_data[:hash][:this]).to eq('is the hash')
        expect(delivery_data['hash']['this']).to eq('is the hash')
      end
    end

    context 'when delivery_options is an array of string' do
      let(:delivery_options) { %w[from to subject body] }
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

      it 'returns back with the right data' do
        expect(delivery_data).to eq(expected_hash)
      end
    end

    context 'when default_data exists' do
      let(:default_delivery_options) { { tag: 'test_tag' } }

      context 'and option does NOT defined in the mail' do
        let(:delivery_options) { %i[from to subject body] }
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
            'body' => 'This is the message body',
            'tag' => 'test_tag'
          }
        end

        it 'returns back with the right data (it adds the default_data)' do
          expect(delivery_data).to eq(expected_hash)
        end
      end

      context 'and option is defined in the mail as well' do
        context 'but delivery_options does NOT contain this option' do
          let(:delivery_options) { %i[from to subject body] }
          let(:message) do
            Mail.new(
              from: 'from@example.com',
              to: 'to@example.com',
              subject: 'This is the message subject',
              body: 'This is the message body',
              tag: 'defined_in_mail'
            )
          end
          let(:expected_hash) do
            {
              'from' => ['from@example.com'],
              'to' => ['to@example.com'],
              'subject' => 'This is the message subject',
              'body' => 'This is the message body',
              'tag' => 'test_tag'
            }
          end

          it 'returns back with the right data (it adds the default_data)' do
            expect(delivery_data).to eq(expected_hash)
          end
        end

        context 'and delivery_options contains this option' do
          let(:delivery_options) { %i[from to subject body tag] }
          let(:message) do
            Mail.new(
              from: 'from@example.com',
              to: 'to@example.com',
              subject: 'This is the message subject',
              body: 'This is the message body',
              tag: 'defined_in_mail'
            )
          end
          let(:expected_hash) do
            {
              'from' => ['from@example.com'],
              'to' => ['to@example.com'],
              'subject' => 'This is the message subject',
              'body' => 'This is the message body',
              'tag' => 'defined_in_mail'
            }
          end

          context 'and the keys of the default_delivery_options are symbols' do
            it 'returns back with the right data (it overrides the ' \
               'default_data)' do
              expect(delivery_data).to eq(expected_hash)
            end
          end

          context 'and the keys of the default_delivery_options are strings' do
            let(:default_delivery_options) { { 'tag' => 'test_tag' } }

            it 'returns back with the right data (it overrides the ' \
               'default_data)' do
              expect(delivery_data).to eq(expected_hash)
            end
          end
        end
      end
    end
  end

  describe '#default_data' do
    subject(:default_data) do
      TestClass
        .new(
          default_delivery_options: default_delivery_options
        )
        .default_data
    end

    context 'when default_delivery_options does NOT a hash' do
      context 'but it is nil' do
        let(:default_delivery_options) { nil }

        it 'returns with empty hash' do
          expect(default_data).to eq({})
        end
      end

      context 'but it is a string' do
        let(:default_delivery_options) { 'default_data' }

        it 'raises error' do
          expect { default_data }
            .to raise_error(MailPlugger::Error::WrongDefaultDeliveryOptions)
        end
      end

      context 'but it is an array' do
        let(:default_delivery_options) { [] }

        it 'raises error' do
          expect { default_data }
            .to raise_error(MailPlugger::Error::WrongDefaultDeliveryOptions)
        end
      end
    end

    context 'when default_delivery_options is a hash' do
      let(:default_delivery_options) { { tag: 'test_tag' } }

      it 'returns with the given hash of the delivery_system' do
        expect(default_data).to eq(default_delivery_options)
      end
    end
  end

  describe '#default_delivery_system_get' do
    subject(:default_delivery_system_get) do
      TestClass
        .new(
          client: client,
          delivery_options: delivery_options,
          delivery_settings: delivery_settings,
          passed_default_delivery_system: passed_default_delivery_system,
          delivery_systems: delivery_systems,
          rotatable_delivery_systems: rotatable_delivery_systems,
          sending_method: sending_method
        )
        .default_delivery_system_get
    end

    let(:client) { nil }
    let(:delivery_options) { nil }
    let(:delivery_settings) { nil }
    let(:passed_default_delivery_system) { nil }
    let(:delivery_systems) { nil }
    let(:rotatable_delivery_systems) { nil }
    let(:sending_method) { nil }

    shared_examples 'returning with the delivery system key' \
                    do |delivery_system_key|
      context 'and delivery_systems exists' do
        let(:delivery_systems) { %w[delivery_system other_delivery_system] }

        if delivery_system_key == 'first'
          it 'returns with the first key' do
            expect(default_delivery_system_get).to eq('delivery_system')
          end
        else
          it 'returns with one of the keys' do
            expect(default_delivery_system_get)
              .to eq('delivery_system').or eq('other_delivery_system')
          end
        end
      end

      context 'and delivery_systems does NOT exist' do
        let(:delivery_systems) { nil }

        context 'and neither delivery_options, client or delivery_settings ' \
                'is a hash' do
          let(:client) { DummyApi }
          let(:delivery_options) { %i[to from subject body] }
          let(:delivery_settings) { nil }

          it 'returns with nil' do
            expect(default_delivery_system_get).to be_nil
          end
        end

        context 'and delivery_options is hash but client and ' \
                'delivery_settings does NOT' do
          let(:client) { DummyApi }
          let(:delivery_options) do
            {
              'delivery_system' => %i[to from subject body],
              'other_delivery_system' => %i[to from subject body]
            }
          end
          let(:delivery_settings) { nil }

          if delivery_system_key == 'first'
            it 'returns with the first key' do
              expect(default_delivery_system_get).to eq('delivery_system')
            end
          else
            it 'returns with one of the keys' do
              expect(default_delivery_system_get)
                .to eq('delivery_system').or eq('other_delivery_system')
            end
          end
        end

        context 'and client is hash but delivery_options and ' \
                'delivery_settings does NOT' do
          let(:client) do
            {
              'delivery_system' => DummyApi,
              'other_delivery_system' => OtherDummyApi
            }
          end
          let(:delivery_options) { %i[to from subject body] }
          let(:delivery_settings) { nil }

          if delivery_system_key == 'first'
            it 'returns with the first key' do
              expect(default_delivery_system_get).to eq('delivery_system')
            end
          else
            it 'returns with one of the keys' do
              expect(default_delivery_system_get)
                .to eq('delivery_system').or eq('other_delivery_system')
            end
          end
        end

        context 'and delivery_settings is hash but delivery_options and ' \
                'client does NOT' do
          let(:client) { DummyApi }
          let(:delivery_options) { %i[to from subject body] }

          context 'and it contains DELIVERY_SETTINGS_KEYS' do
            let(:delivery_settings) { { return_response: true } }

            it 'returns with nil' do
              expect(default_delivery_system_get).to be_nil
            end
          end

          context 'and it does NOT contain DELIVERY_SETTINGS_KEYS' do
            let(:delivery_settings) do
              {
                'delivery_system' => { return_response: true },
                'other_delivery_system' => { return_response: true }
              }
            end

            if delivery_system_key == 'first'
              it 'returns with the first key' do
                expect(default_delivery_system_get).to eq('delivery_system')
              end
            else
              it 'returns with one of the keys' do
                expect(default_delivery_system_get)
                  .to eq('delivery_system').or eq('other_delivery_system')
              end
            end
          end
        end

        context 'and all delivery_options, client and delivery_settings ' \
                'are hashes' do
          let(:client) do
            {
              'delivery_system' => DummyApi,
              'other_delivery_system' => OtherDummyApi
            }
          end
          let(:delivery_options) do
            {
              'delivery_system' => %i[to from subject body],
              'other_delivery_system' => %i[to from subject body]
            }
          end
          let(:delivery_settings) do
            {
              'delivery_system' => { return_response: true },
              'other_delivery_system' => { return_response: true }
            }
          end

          if delivery_system_key == 'first'
            it 'returns with the first key' do
              expect(default_delivery_system_get).to eq('delivery_system')
            end
          else
            it 'returns with one of the keys' do
              expect(default_delivery_system_get)
                .to eq('delivery_system').or eq('other_delivery_system')
            end
          end
        end
      end
    end

    context 'when sending_method is default_delivery_system' do
      let(:sending_method) { :default_delivery_system }

      context 'and passed_default_delivery_system does NOT exist' do
        let(:passed_default_delivery_system) { nil }

        it_behaves_like 'returning with the delivery system key', 'first'
      end

      context 'and passed_default_delivery_system exists' do
        let(:passed_default_delivery_system) { 'delivery_system' }

        it 'returns with the passed_default_delivery_system' do
          expect(default_delivery_system_get).to eq('delivery_system')
        end
      end
    end

    context 'when sending_method is plugged_in_first' do
      let(:sending_method) { :plugged_in_first }

      it_behaves_like 'returning with the delivery system key', 'first'
    end

    context 'when sending_method is random' do
      let(:sending_method) { :random }

      it_behaves_like 'returning with the delivery system key', 'random'
    end

    context 'when sending_method is round_robin' do
      let(:sending_method) { :round_robin }

      context 'and rotatable_delivery_systems does NOT exist' do
        let(:rotatable_delivery_systems) { nil }

        it 'returns with nil' do
          expect(default_delivery_system_get).to be_nil
        end
      end

      context 'and rotatable_delivery_systems exists' do
        subject(:default_delivery_system_get) do
          proc do
            TestClass
              .new(
                rotatable_delivery_systems: rotatable_delivery_systems,
                sending_method: sending_method
              )
              .default_delivery_system_get
          end
        end

        let(:rotatable_delivery_systems) do
          %w[delivery_system1 delivery_system2].cycle
        end

        it 'returns with the cycle of the delivery system keys' do
          expect(default_delivery_system_get.call).to eq('delivery_system1')
          expect(default_delivery_system_get.call).to eq('delivery_system2')
          expect(default_delivery_system_get.call).to eq('delivery_system1')
          expect(default_delivery_system_get.call).to eq('delivery_system2')
        end
      end
    end

    context 'when sending_method is nil' do
      let(:sending_method) { nil }

      context 'and passed_default_delivery_system does NOT exist' do
        let(:passed_default_delivery_system) { nil }

        it_behaves_like 'returning with the delivery system key', 'first'
      end

      context 'and passed_default_delivery_system exists' do
        let(:passed_default_delivery_system) { 'delivery_system' }

        it 'returns with the passed_default_delivery_system' do
          expect(default_delivery_system_get).to eq('delivery_system')
        end
      end
    end
  end

  describe '#delivery_options' do
    subject(:delivery_options) do
      TestClass
        .new(delivery_options: options, message: message)
        .delivery_options
    end

    let(:message) { Mail.new(delivery_system: 'delivery_system') }

    context 'when delivery_options does NOT an array' do
      let(:options) { 'to from subject body' }

      it 'raises error' do
        expect { delivery_options }
          .to raise_error(MailPlugger::Error::WrongDeliveryOptions)
      end
    end

    context 'when delivery_options does NOT a hash' do
      let(:options) { %i[to from subject body] }

      it 'returns with the given array' do
        expect(delivery_options).to eq(options)
      end
    end

    context 'when delivery_options is a hash' do
      let(:options) do
        {
          'delivery_system' => %i[to from subject body],
          'other_delivery_system' => %i[to from subject text_part html_part]
        }
      end

      it 'returns with the right array from the hash' do
        expect(delivery_options).to eq(options['delivery_system'])
      end
    end
  end

  describe '#delivery_system' do
    subject(:delivery_system) do
      TestClass
        .new(
          client: client,
          delivery_options: delivery_options,
          delivery_settings: delivery_settings,
          default_delivery_system: default_delivery_system,
          message: message
        )
        .delivery_system
    end

    context 'when message does NOT exist' do
      let(:client) { nil }
      let(:delivery_options) { nil }
      let(:delivery_settings) { nil }
      let(:default_delivery_system) { nil }
      let(:message) { nil }

      it 'does NOT raise error' do
        expect { delivery_system }.not_to raise_error
      end
    end

    context 'when message exists' do
      let(:message) { Mail.new(mail_options) }

      context 'and all delivery_options, client and delivery_settings ' \
              'are hashes' do
        let(:client) { { 'delivery_system' => DummyApi } }
        let(:delivery_options) do
          { 'delivery_system' => %i[to from subject body] }
        end
        let(:delivery_settings) do
          { 'delivery_system' => { return_response: true } }
        end

        context 'and default_delivery_system is defined' do
          let(:default_delivery_system) { 'delivery_system' }
          let(:mail_options) { {} }

          it 'returns with the default_delivery_system' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system is defined in Mail::Message object' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { { delivery_system: 'delivery_system' } }

          it 'returns with the delivery_system from Mail::Message' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system does NOT defined' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { {} }

          it 'raises error' do
            expect { delivery_system }
              .to raise_error(MailPlugger::Error::WrongDeliverySystem)
          end
        end
      end

      context 'and one of the delivery_options, client or delivery_settings ' \
              'is a hash' do
        let(:client) { DummyApi }
        let(:delivery_options) do
          { 'delivery_system' => %i[to from subject body] }
        end
        let(:delivery_settings) { nil }

        context 'and default_delivery_system is defined' do
          let(:default_delivery_system) { 'delivery_system' }
          let(:mail_options) { {} }

          it 'returns with the default_delivery_system' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system is defined in Mail::Message object' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { { delivery_system: 'delivery_system' } }

          it 'returns with the delivery_system from Mail::Message' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system does NOT defined' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { {} }

          it 'raises error' do
            expect { delivery_system }
              .to raise_error(MailPlugger::Error::WrongDeliverySystem)
          end
        end
      end

      context 'and none of the delivery_options, client and ' \
              'delivery_settings are hashes' do
        let(:client) { DummyApi }
        let(:delivery_options) { %i[to from subject body] }
        let(:delivery_settings) { nil }

        context 'and default_delivery_system is defined' do
          let(:default_delivery_system) { 'delivery_system' }
          let(:mail_options) { {} }

          it 'returns with the default_delivery_system' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system is defined in Mail::Message object' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { { delivery_system: 'delivery_system' } }

          it 'returns with the delivery_system from Mail::Message' do
            expect(delivery_system).to eq('delivery_system')
          end
        end

        context 'and delivery_system does NOT defined' do
          let(:default_delivery_system) { nil }
          let(:mail_options) { {} }

          it 'returns with nil' do
            expect(delivery_system).to be_nil
          end
        end
      end

      context 'and calls delivery_system more time' do
        let(:delivery_method) do
          TestClass
            .new(
              client: client,
              delivery_options: delivery_options,
              delivery_settings: delivery_settings,
              default_delivery_system: default_delivery_system,
              message: message
            )
        end
        let(:client) { nil }
        let(:delivery_options) { nil }
        let(:delivery_settings) { nil }
        let(:default_delivery_system) { nil }
        let(:mail_options) { { delivery_system: 'delivery_system' } }

        before { delivery_method.delivery_system }

        it 'sets delivery_system with the right value' do
          expect(delivery_method.instance_variable_get(:@delivery_system))
            .to eq(mail_options[:delivery_system])
        end

        it 'returns back with the memoized value' do
          allow(delivery_method).to receive(:message_field_value_from)
            .and_call_original

          delivery_method.delivery_system
          expect(delivery_method)
            .not_to have_received(:message_field_value_from)
        end
      end
    end
  end

  describe '#extract_keys' do
    context 'when delivery_systems exists' do
      subject(:extract_keys) do
        TestClass.new(delivery_systems: delivery_systems).extract_keys
      end

      let(:delivery_systems) { %w[key1 key2] }

      it 'returns with delivery_systems array' do
        expect(extract_keys).to eq(delivery_systems)
      end
    end

    context 'when delivery_systems does NOT exist' do
      subject(:extract_keys) do
        TestClass
          .new(
            client: client,
            delivery_options: delivery_options,
            delivery_settings: delivery_settings
          )
          .extract_keys
      end

      context 'and delivery_options is a hash' do
        let(:client) { nil }
        let(:delivery_options) { { key1: :value1, key2: :value2 } }
        let(:delivery_settings) { nil }

        it 'returns with the keys' do
          expect(extract_keys).to eq(%i[key1 key2])
        end
      end

      context 'and client is a hash' do
        let(:client) { { 'key1' => 'value1', 'key2' => 'value2' } }
        let(:delivery_options) { nil }
        let(:delivery_settings) { nil }

        it 'returns with the keys' do
          expect(extract_keys).to eq(%w[key1 key2])
        end
      end

      context 'and both delivery_options and client are hashes' do
        # both delivery_options and client should have the same keys,
        # but now we can see that the delivery_options keys will be returned,
        # which should be ok.
        let(:client) { { key3: :value3, key4: :value4 } }
        let(:delivery_options) { { key1: :value1, key2: :value2 } }
        let(:delivery_settings) { nil }

        it 'returns with the first hash keys' do
          expect(extract_keys).to eq(%i[key1 key2])
        end
      end

      context 'and delivery_settings is a hash' do
        let(:client) { nil }
        let(:delivery_options) { nil }

        context 'but it contains only DELIVERY_SETTINGS_KEYS' do
          let(:delivery_settings) { { return_response: true } }

          it 'returns with nil' do
            expect(extract_keys).to be_nil
          end
        end

        context 'but it contains one of DELIVERY_SETTINGS_KEYS' do
          let(:delivery_settings) do
            { 'key' => 'value', 'return_response' => true }
          end

          it 'returns with nil' do
            expect(extract_keys).to be_nil
          end
        end

        context 'and it does NOT contain DELIVERY_SETTINGS_KEYS ' \
                '(in the first level)' do
          let(:delivery_settings) { { 'key' => { return_response: true } } }

          it 'returns with the keys' do
            expect(extract_keys).to eq(%w[key])
          end
        end
      end

      context 'when none of the options are hashes' do
        let(:client) { nil }
        let(:delivery_options) { nil }
        let(:delivery_settings) { nil }

        it 'returns with nil' do
          expect(extract_keys).to be_nil
        end
      end
    end
  end

  describe '#mail_field_value' do
    subject(:field_value) { TestClass.new.mail_field_value }

    before do
      allow(Gem.loaded_specs['mail']).to receive(:version).and_return(version)
    end

    context 'when the mail gem version is > 2.7.0' do
      let(:version) { Gem::Version.new('2.7.1') }

      it 'returns with the right method string' do
        expect(field_value).to eq(['unparsed_value'])
      end
    end

    context 'when the mail gem version is = 2.7.0' do
      let(:version) { Gem::Version.new('2.7.0') }

      it 'returns with the right method string' do
        expect(field_value).to eq(['instance_variable_get', '@unparsed_value'])
      end
    end

    context 'when the mail gem version is < 2.7.0' do
      let(:version) { Gem::Version.new('2.6.9') }

      it 'returns with the right method string' do
        expect(field_value).to eq(['instance_variable_get', '@value'])
      end
    end
  end

  describe '#message_field_value_from' do
    subject(:value) { TestClass.new.message_field_value_from(message_field) }

    let(:message) { Mail.new(mail_options) }

    context 'when field does not exist' do
      let(:mail_options) { {} }
      let(:message_field) { message['unknown'] }

      it 'returns with nil' do
        expect(value).to be_nil
      end
    end

    context 'when field exists' do
      let(:message_field) { message['test_field'] }

      context 'and value is a string' do
        let(:mail_options) { { test_field: 'test_field_value' } }

        it 'returns with the string' do
          expect(value).to eq('test_field_value')
        end
      end

      context 'and value is a symbol' do
        let(:mail_options) { { test_field: :test_field_value } }

        it 'returns with the symbol' do
          expect(value).to eq(:test_field_value)
        end
      end

      context 'and value is a boolean' do
        let(:mail_options) { { test_field: true } }

        it 'returns with the boolean' do
          expect(value).to be true
        end
      end

      context 'and value is a hash' do
        let(:mail_options) do
          { test_field: { test_field_key: 'test_field_value' } }
        end

        it 'returns with the hash' do
          expect(value).to eq({ 'test_field_key' => 'test_field_value' })
        end
      end

      context 'and value is a array' do
        let(:mail_options) do
          { test_field: [:test_field_value1, 'test_field_value2'] }
        end

        it 'returns with the array' do
          expect(value).to eq([:test_field_value1, 'test_field_value2'])
        end
      end
    end
  end

  describe '#option_value_from' do
    subject(:value) do
      TestClass.new(message: message).option_value_from(option)
    end

    let(:message) { Mail.new(delivery_system: 'key') }

    context 'when option does NOT a hash' do
      context 'and option is a string' do
        let(:option) { 'option' }

        it 'returns with the given value' do
          expect(value).to eq(option)
        end
      end

      context 'and option is nil' do
        let(:option) { nil }

        it 'returns with nil' do
          expect(value).to be_nil
        end
      end
    end

    context 'when option is a hash' do
      context 'and it does NOT find the key' do
        let(:option) { {} }

        it 'returns with the given hash' do
          expect(value).to eq(option)
        end
      end

      context 'and it finds the key' do
        let(:option) { { 'key' => 'value' } }

        it 'returns with the right value from the hash' do
          expect(value).to eq(option['key'])
        end
      end
    end
  end

  describe '#send_via_smtp?' do
    subject(:send_via_smtp) do
      TestClass.new(delivery_settings: delivery_settings).send_via_smtp?
    end

    context 'when settings does NOT contain smtp_settings' do
      let(:delivery_settings) { nil }

      it 'returns with false' do
        expect(send_via_smtp).to be false
      end
    end

    context 'when settings contains smtp_settings' do
      context 'but it does NOT a hash' do
        let(:delivery_settings) { { smtp_settings: nil } }

        it 'returns with false' do
          expect(send_via_smtp).to be false
        end
      end

      context 'and it is a hash' do
        context 'but empty' do
          let(:delivery_settings) { { smtp_settings: {} } }

          it 'returns with false' do
            expect(send_via_smtp).to be false
          end
        end

        context 'and it has settings' do
          let(:delivery_settings) { { smtp_settings: { key: 'value' } } }

          it 'returns with true' do
            expect(send_via_smtp).to be true
          end
        end
      end
    end
  end

  describe '#sending_method_get' do
    subject(:sending_method_get) do
      TestClass
        .new(
          passed_default_delivery_system: passed_default_delivery_system,
          sending_method: sending_method
        )
        .sending_method_get
    end

    context 'when sending_method does NOT exist' do
      let(:sending_method) { nil }

      context 'and passed_default_delivery_system does NOT exist' do
        let(:passed_default_delivery_system) { nil }

        it 'returns with plugged_in_first' do
          expect(sending_method_get).to eq(:plugged_in_first)
        end
      end

      context 'and passed_default_delivery_system exists' do
        let(:passed_default_delivery_system) { 'delivery_system' }

        it 'returns with default_delivery_system' do
          expect(sending_method_get).to eq(:default_delivery_system)
        end
      end
    end

    context 'when sending_method exists' do
      context 'and sending_method does NOT include in ' \
              'DELIVERY_SENDING_METHODS' do
        let(:passed_default_delivery_system) { nil }
        let(:sending_method) { :not_exist }

        it 'returns with plugged_in_first' do
          expect(sending_method_get).to eq(:plugged_in_first)
        end
      end

      context 'and sending_method includes in DELIVERY_SENDING_METHODS' do
        shared_examples 'returning with the right sending_method' do |method|
          context "and sending_method is equal to #{method}" do
            let(:sending_method) { method }

            context 'and passed_default_delivery_system does NOT exist' do
              let(:passed_default_delivery_system) { nil }

              it "returns with #{method}" do
                expect(sending_method_get).to eq(sending_method)
              end
            end

            context 'and passed_default_delivery_system exists' do
              let(:passed_default_delivery_system) { 'delivery_system' }

              it "returns with #{method}" do
                expect(sending_method_get).to eq(sending_method)
              end
            end
          end
        end

        context 'and sending_method is equal to default_delivery_system' do
          let(:sending_method) { :default_delivery_system }

          context 'and passed_default_delivery_system does NOT exist' do
            let(:passed_default_delivery_system) { nil }

            it 'returns with plugged_in_first' do
              expect(sending_method_get).to eq(:plugged_in_first)
            end
          end

          context 'and passed_default_delivery_system exists' do
            let(:passed_default_delivery_system) { 'delivery_system' }

            it 'returns with default_delivery_system' do
              expect(sending_method_get).to eq(:default_delivery_system)
            end
          end
        end

        it_behaves_like 'returning with the right sending_method',
                        :plugged_in_first

        it_behaves_like 'returning with the right sending_method', :random

        it_behaves_like 'returning with the right sending_method', :round_robin
      end
    end
  end

  describe '#settings' do
    subject(:settings) do
      TestClass
        .new(
          delivery_settings: delivery_settings,
          default_delivery_system: default_delivery_system
        )
        .settings
    end

    let(:default_delivery_system) { nil }

    context 'when delivery_settings does NOT a hash' do
      context 'but it is nil' do
        let(:delivery_settings) { nil }

        it 'returns with empty hash' do
          expect(settings).to eq({})
        end
      end

      context 'but it is string' do
        let(:delivery_settings) { 'settings' }

        it 'raises error' do
          expect { settings }
            .to raise_error(MailPlugger::Error::WrongDeliverySettings)
        end
      end
    end

    context 'when delivery_settings is a hash' do
      context 'and delivery_system does NOT defined anywhere' do
        context 'but it contains only DELIVERY_SETTINGS_KEYS' do
          let(:delivery_settings) { { return_response: true } }

          it 'returns with the delivery_settings' do
            expect(settings).to eq(delivery_settings)
          end
        end

        context 'but it contains one of DELIVERY_SETTINGS_KEYS' do
          let(:delivery_settings) do
            { 'key' => 'value', 'return_response' => true }
          end

          it 'returns with the delivery_settings (transformed the hash keys' \
             'to symbol)' do
            expect(settings).to eq(delivery_settings.transform_keys(&:to_sym))
          end
        end

        context 'and it does NOT contain DELIVERY_SETTINGS_KEYS ' \
                '(in the first level)' do
          let(:delivery_settings) { { 'key' => { return_response: true } } }

          it 'raises error' do
            expect { settings }
              .to raise_error(MailPlugger::Error::WrongDeliverySystem)
          end
        end
      end

      context 'and delivery_system is defined somehow' do
        let(:default_delivery_system) { 'delivery_system' }

        context 'but it contains only DELIVERY_SETTINGS_KEYS' do
          let(:delivery_settings) { { return_response: true } }

          it 'returns with the delivery_settings' do
            expect(settings).to eq(delivery_settings)
          end
        end

        context 'but it contains one of DELIVERY_SETTINGS_KEYS' do
          context 'and the value of the delivery_system does NOT a hash' do
            let(:delivery_settings) do
              { 'delivery_system' => 'value', 'return_response' => true }
            end

            it 'raises error' do
              expect { settings }
                .to raise_error(MailPlugger::Error::WrongDeliverySettings)
            end
          end

          context 'and the value of the delivery_system is a hash' do
            let(:delivery_settings) do
              { 'delivery_system' => {}, 'return_response' => true }
            end

            it 'returns with the extracted delivery_settings' do
              expect(settings).to eq(delivery_settings['delivery_system'])
            end
          end
        end

        context 'and it does NOT contain DELIVERY_SETTINGS_KEYS ' \
                '(in the first level)' do
          let(:delivery_settings) do
            { 'delivery_system' => { return_response: true } }
          end

          it 'returns with the extracted delivery_settings' do
            expect(settings).to eq(delivery_settings['delivery_system'])
          end
        end
      end
    end

    context 'and calls settings more time' do
      let(:delivery_method) do
        TestClass
          .new(
            delivery_settings: delivery_settings,
            default_delivery_system: default_delivery_system
          )
      end
      let(:default_delivery_system) { 'delivery_system' }
      let(:delivery_settings) do
        { 'delivery_system' => { return_response: true } }
      end

      before { delivery_method.settings }

      it 'sets settings with the right value' do
        expect(delivery_method.instance_variable_get(:@settings))
          .to eq(delivery_settings['delivery_system'])
      end

      it 'returns back with the memoized value' do
        allow(delivery_method).to receive(:option_value_from).and_call_original

        delivery_method.settings
        expect(delivery_method).not_to have_received(:option_value_from)
      end
    end
  end
end
