# frozen_string_literal: true

module FakePlugger
  class Railtie < Rails::Railtie
    initializer 'fake_plugger.add_delivery_method' do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method(
          :fake_plugger,
          FakePlugger::DeliveryMethod
        )
      end
    end
  end
end
