# How to use SendGrid API with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use mailer method which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Add `sendgrid-ruby` gem to the `Gemfile`.

```ruby
gem 'sendgrid-ruby'
```

Then run `bundle install` command to deploy the gem.

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class SendGridApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['SENDGRID_API_KEY'] }
    @options = options
  end

  def deliver
    SendGrid::API.new(@settings).client.mail._("send").post(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      request_body: {
        personalizations: [
          {
            to: generate_recipients,
            subject: @options[:subject]
          }
        ],
        from: {
          email: @options[:from].first
        },
        content: [
          {
            type: 'text/plain',
            value: @options[:text_part]
          },
          {
            type: 'text/html',
            value: @options[:html_part]
          }
        ]
      }
    }
  end

  def generate_recipients
    @options[:to].map do |to|
      {
        email: to
      }
    end
  end
end

MailPlugger.plug_in('sendgrid') do |api|
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
  api.client = SendGridApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'sendgrid'
  end
end
```
