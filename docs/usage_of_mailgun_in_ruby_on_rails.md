# How to use Mailgun with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use mailer method which was defined [here](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md).

Add `mailgun-ruby` gem to the `Gemfile`.

```ruby
gem 'mailgun-ruby'
```

Then run `bundle install` command to deploy the gem.

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class MailgunApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['MAILGUN_API_KEY'] }
    @options = options
  end

  def deliver
    Mailgun::Client.new(@settings[:api_key]).send_message('sending_domain.com', generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      from: @options[:from].first,
      to: @options[:to].join(','),
      subject: @options[:subject],
      text: @options[:text_part],
      html: @options[:html_part]
    }
  end
end

MailPlugger.plug_in('mailgun') do |api|
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
  api.client = MailgunApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'mailgun'
  end
end
```
