# frozen_string_literal: true

RSpec.shared_examples 'fake_plugger/delivery_method/deliver/' \
                      'with_initialize_arguments/when_using_smtp' do
  context 'when using SMTP' do
    context 'and without deliver! method paramemter' do
      subject(:deliver) do
        described_class.new(
          default_delivery_system: delivery_system,
          delivery_settings: delivery_settings
        ).deliver!
      end

      it 'raises error' do
        expect { deliver }.to raise_error(ArgumentError)
      end
    end

    context 'and the deliver! method has paramemter' do
      subject(:deliver) do
        described_class.new(
          default_delivery_system: default_delivery_system,
          delivery_settings: delivery_settings
        ).deliver!(message)
      end

      context 'but message paramemter does NOT a Mail::Message object' do
        let(:default_delivery_system) { nil }
        let(:message) { nil }

        it 'raises error' do
          expect { deliver }.to raise_error(MailPlugger::Error::WrongParameter)
        end
      end

      context 'and message paramemter is a Mail::Message object' do
        before { allow(message).to receive(:deliver!) }

        context 'and default_delivery_system does NOT defined' do
          let(:default_delivery_system) { nil }

          context 'when delivery_settings is a hash' do
            context 'and delivery_settings does NOT contain delivery_system' do
              context 'and delivery_settings does NOT contain smtp_settings' do
                context 'but delivery_settings contains ' \
                        'one of DELIVERY_SETTINGS_KEYS' do
                  let(:delivery_settings) { { return_response: true } }

                  context 'but message does NOT contain ' \
                          'delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end

                context 'and delivery_settings does NOT contain ' \
                        'DELIVERY_SETTINGS_KEYS (in the first level)' do
                  let(:delivery_settings) { { key: 'value' } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongDeliverySettings
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end
                  end
                end
              end

              context 'and delivery_settings contains smtp_settings' do
                let(:delivery_settings) do
                  {
                    smtp_settings: { key: 'value' },
                    return_response: true
                  }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'returns with the message' do
                    expect(deliver).to eq(message)
                  end
                end

                context 'and message contains delivery_system' do
                  # In this case delivey_settings does not contain
                  # delivery_system, so the delivey_system is not
                  # important.
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) { Mail.new(delivery_system: delivery_system) }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end
                end
              end
            end

            context 'and delivery_settings contains delivery_system' do
              context 'and delivery_settings does NOT contain smtp_settings' do
                context 'but delivery_settings contains ' \
                        'one of DELIVERY_SETTINGS_KEYS' do
                  let(:delivery_settings) do
                    { delivery_system => { return_response: true } }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end

                context 'and delivery_settings does NOT contain ' \
                        'DELIVERY_SETTINGS_KEYS (in the first level)' do
                  let(:delivery_settings) do
                    { delivery_system => { key: 'value' } }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end
              end

              context 'and delivery_settings contains smtp_settings' do
                let(:delivery_settings) do
                  {
                    delivery_system => {
                      smtp_settings: { key: 'value' },
                      return_response: true
                    }
                  }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'returns with the message' do
                    expect(deliver).to eq(message)
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongDeliverySystem
                      )
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) do
                      Mail.new(delivery_system: delivery_system)
                    end

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end
                end
              end
            end
          end

          context 'when delivery_settings does NOT a hash' do
            context 'and delivery_settings is nil' do
              let(:delivery_settings) { nil }

              context 'but message does NOT contain delivery_system' do
                let(:message) { Mail.new }

                it 'raises error' do
                  expect { deliver }.to raise_error(
                    MailPlugger::Error::WrongApiClient
                  )
                end
              end

              context 'and message contains delivery_system' do
                context 'but the given delivery_system does NOT exist' do
                  let(:message) { Mail.new(delivery_system: 'key') }

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongApiClient
                    )
                  end
                end

                context 'and the given delivery_system exists' do
                  let(:message) { Mail.new(delivery_system: delivery_system) }

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongApiClient
                    )
                  end
                end
              end
            end

            context 'and delivery_settings is string' do
              let(:delivery_settings) { 'settings' }

              context 'but message does NOT contain delivery_system' do
                let(:message) { Mail.new }

                it 'raises error' do
                  expect { deliver }.to raise_error(
                    MailPlugger::Error::WrongDeliverySettings
                  )
                end
              end

              context 'and message contains delivery_system' do
                context 'but the given delivery_system does NOT exist' do
                  let(:message) { Mail.new(delivery_system: 'key') }

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongDeliverySettings
                    )
                  end
                end

                context 'and the given delivery_system exists' do
                  let(:message) do
                    Mail.new(delivery_system: delivery_system)
                  end

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongDeliverySettings
                    )
                  end
                end
              end
            end
          end
        end

        context 'and default_delivery_system is defined' do
          let(:default_delivery_system) { delivery_system }

          context 'when delivery_settings is a hash' do
            context 'and delivery_settings does NOT contain delivery_system' do
              context 'and delivery_settings does NOT contain smtp_settings' do
                context 'but delivery_settings contains ' \
                        'one of DELIVERY_SETTINGS_KEYS' do
                  let(:delivery_settings) { { return_response: true } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end

                context 'and delivery_settings does NOT contain ' \
                        'DELIVERY_SETTINGS_KEYS (in the first level)' do
                  let(:delivery_settings) { { key: 'value' } }

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongDeliverySystem
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end
                  end
                end
              end

              context 'and delivery_settings contains smtp_settings' do
                let(:delivery_settings) do
                  {
                    smtp_settings: { key: 'value' },
                    return_response: true
                  }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'returns with the message' do
                    expect(deliver).to eq(message)
                  end
                end

                context 'and message contains delivery_system' do
                  # In this case delivey_settings does not contain
                  # delivery_system, so the delivey_system is not
                  # important.
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) do
                      Mail.new(delivery_system: delivery_system)
                    end

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end
                end
              end
            end

            context 'and delivery_settings contains delivery_system' do
              context 'and delivery_settings does NOT contain smtp_settings' do
                context 'but delivery_settings contains ' \
                        'one of DELIVERY_SETTINGS_KEYS' do
                  let(:delivery_settings) do
                    { delivery_system => { return_response: true } }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end

                context 'and delivery_settings does NOT contain ' \
                        'DELIVERY_SETTINGS_KEYS (in the first level)' do
                  let(:delivery_settings) do
                    { delivery_system => { key: 'value' } }
                  end

                  context 'but message does NOT contain delivery_system' do
                    let(:message) { Mail.new }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongApiClient
                      )
                    end
                  end

                  context 'and message contains delivery_system' do
                    context 'but the given delivery_system does NOT exist' do
                      let(:message) { Mail.new(delivery_system: 'key') }

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongDeliverySystem
                        )
                      end
                    end

                    context 'and the given delivery_system exists' do
                      let(:message) do
                        Mail.new(delivery_system: delivery_system)
                      end

                      it 'raises error' do
                        expect { deliver }.to raise_error(
                          MailPlugger::Error::WrongApiClient
                        )
                      end
                    end
                  end
                end
              end

              context 'and delivery_settings contains smtp_settings' do
                let(:delivery_settings) do
                  {
                    delivery_system => {
                      smtp_settings: { key: 'value' },
                      return_response: true
                    }
                  }
                end

                context 'but message does NOT contain delivery_system' do
                  let(:message) { Mail.new }

                  it 'does NOT raise error' do
                    expect { deliver }.not_to raise_error
                  end

                  it 'returns with the message' do
                    expect(deliver).to eq(message)
                  end
                end

                context 'and message contains delivery_system' do
                  context 'but the given delivery_system does NOT exist' do
                    let(:message) { Mail.new(delivery_system: 'key') }

                    it 'raises error' do
                      expect { deliver }.to raise_error(
                        MailPlugger::Error::WrongDeliverySystem
                      )
                    end
                  end

                  context 'and the given delivery_system exists' do
                    let(:message) do
                      Mail.new(delivery_system: delivery_system)
                    end

                    it 'does NOT raise error' do
                      expect { deliver }.not_to raise_error
                    end

                    it 'returns with the message' do
                      expect(deliver).to eq(message)
                    end
                  end
                end
              end
            end
          end

          context 'when delivery_settings does NOT a hash' do
            context 'and delivery_settings is nil' do
              let(:delivery_settings) { nil }

              context 'but message does NOT contain delivery_system' do
                let(:message) { Mail.new }

                it 'raises error' do
                  expect { deliver }.to raise_error(
                    MailPlugger::Error::WrongApiClient
                  )
                end
              end

              context 'and message contains delivery_system' do
                context 'but the given delivery_system does NOT exist' do
                  let(:message) { Mail.new(delivery_system: 'key') }

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongApiClient
                    )
                  end
                end

                context 'and the given delivery_system exists' do
                  let(:message) do
                    Mail.new(delivery_system: delivery_system)
                  end

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongApiClient
                    )
                  end
                end
              end
            end

            context 'and delivery_settings is string' do
              let(:delivery_settings) { 'settings' }

              context 'but message does NOT contain delivery_system' do
                let(:message) { Mail.new }

                it 'raises error' do
                  expect { deliver }.to raise_error(
                    MailPlugger::Error::WrongDeliverySettings
                  )
                end
              end

              context 'and message contains delivery_system' do
                context 'but the given delivery_system does NOT exist' do
                  let(:message) { Mail.new(delivery_system: 'key') }

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongDeliverySettings
                    )
                  end
                end

                context 'and the given delivery_system exists' do
                  let(:message) do
                    Mail.new(delivery_system: delivery_system)
                  end

                  it 'raises error' do
                    expect { deliver }.to raise_error(
                      MailPlugger::Error::WrongDeliverySettings
                    )
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
