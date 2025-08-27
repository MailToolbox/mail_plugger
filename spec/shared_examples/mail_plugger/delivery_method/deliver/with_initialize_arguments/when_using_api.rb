# frozen_string_literal: true

RSpec.shared_examples 'mail_plugger/delivery_method/deliver/' \
                      'with_initialize_arguments/when_using_api' do
  context 'when using API' do
    context 'and without deliver! method paramemter' do
      subject(:deliver) do
        described_class.new(
          client: client,
          delivery_options: delivery_options,
          default_delivery_system: delivery_system
        ).deliver!
      end

      it 'raises error' do
        expect { deliver }.to raise_error(ArgumentError)
      end
    end

    context 'and the deliver! method has paramemter' do
      subject(:deliver) do
        described_class.new(
          client: client,
          delivery_options: delivery_options,
          default_delivery_system: default_delivery_system
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
        shared_examples 'delivers the message' do
          let(:client_object) { instance_double(DummyApi, deliver: true) }

          before { allow(DummyApi).to receive(:new).and_return(client_object) }

          it 'does NOT raise error' do
            expect { deliver }.not_to raise_error
          end

          it 'calls deliver method of the client' do
            deliver
            expect(client_object).to have_received(:deliver)
          end
        end

        context 'and default_delivery_system does NOT defined' do
          let(:default_delivery_system) { nil }

          context 'when both delivery_options and client are hashes' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end
            let(:client) { { delivery_system => DummyApi } }

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              # It won't raise error because it gets delivery_system from
              # the hash key
              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end

          context 'when one of the delivery_options and client is a hash' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end

          context 'when none of the delivery_options and client are hashes' do
            # In this case delivey_options and client are not hashes, so the
            # delivery_system is not important.
            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it_behaves_like 'delivers the message'
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end
        end

        context 'and default_delivery_system is defined' do
          let(:default_delivery_system) { delivery_system }

          context 'when both delivery_options and client are hashes' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end
            let(:client) { { delivery_system => DummyApi } }

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              # It won't raise error because the default_delivery_system is
              # defined
              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                # It raises error because it overrides the
                # default_delivery_system
                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                context 'and delivery_system value is string' do
                  let(:delivery_system) { 'delivery_system' }

                  it_behaves_like 'delivers the message'
                end

                context 'and delivery_system value is symbol' do
                  let(:delivery_system) { :delivery_system }

                  it_behaves_like 'delivers the message'
                end
              end
            end
          end

          context 'when one of the delivery_options and client is a hash' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              # It won't raise error because the default_delivery_system is
              # defined
              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end

          context 'when none of the delivery_options and client are hashes' do
            # In this case delivey_options and client are not hashes, so the
            # delivery_system is not important.
            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it_behaves_like 'delivers the message'
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end
        end

        context 'and default_delivery_system is defined but with a wrong ' \
                'value' do
          let(:default_delivery_system) { 'wrong_value' }

          context 'when both delivery_options and client are hashes' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end
            let(:client) { { delivery_system => DummyApi } }

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              # It raises error because the default_delivery_system is wrong
              # and delivery_options method gets nil value which is not
              # Array
              it 'raises error' do
                expect { deliver }
                  .to raise_error(MailPlugger::Error::WrongDeliverySystem)
              end
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                # It raises error because it overrides the
                # default_delivery_system and this also wrong
                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end

          context 'when one of the delivery_options and client is a hash' do
            let(:delivery_options) do
              { delivery_system => %i[to from subject body] }
            end

            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              # It raises error because the default_delivery_system is wrong
              # and delivery_options method gets nil value which is not
              # Array
              it 'raises error' do
                expect { deliver }
                  .to raise_error(MailPlugger::Error::WrongDeliverySystem)
              end
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                # It raises error because it overrides the
                # default_delivery_system and this also wrong
                it 'raises error' do
                  expect { deliver }
                    .to raise_error(MailPlugger::Error::WrongDeliverySystem)
                end
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end

          context 'when none of the delivery_options and client are hashes' do
            # In this case delivey_options and client are not hashes, so the
            # delivery_system is not important.
            context 'but message does NOT contain delivery_system' do
              let(:message) { Mail.new }

              it_behaves_like 'delivers the message'
            end

            context 'and message contains delivery_system' do
              context 'but the given delivery_system does NOT exist' do
                let(:message) { Mail.new(delivery_system: 'key') }

                it_behaves_like 'delivers the message'
              end

              context 'and the given delivery_system exists' do
                let(:message) { Mail.new(delivery_system: delivery_system) }

                it_behaves_like 'delivers the message'
              end
            end
          end
        end
      end
    end
  end
end
