# frozen_string_literal: true

module MailPlugger
  class Railtie < Rails::Railtie
    initializer 'mail_plugger.add_delivery_method' do
      ActiveSupport.on_load :action_mailer do
        ActionMailer::Base.add_delivery_method(
          :mail_plugger,
          MailPlugger::DeliveryMethod
        )
      end
    end
  end
end
