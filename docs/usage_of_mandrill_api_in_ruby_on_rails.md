**Go To:**

- [How to use Mandrill API with MailPlugger in Ruby on Rails](#how-to-use-mandrill-api-with-mailplugger-in-ruby-on-rails)
  - [Send](#send)
  - [Send Raw](#send-raw)


# How to use Mandrill API with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use mailer method which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Add `mandrill-api-json` gem to the `Gemfile`.

```ruby
gem 'mandrill-api-json'
```

Then run `bundle install` command to deploy the gem.

## Send

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class MandrillApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['MANDRILL_API_KEY'] }
    @options = options
  end

  def deliver
    Mandrill::API.new(@settings[:api_key]).messages.send(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      from_email: @options[:from].first,
      to: generate_recipients,
      subject: @options[:subject],
      text: @options[:text_part],
      html: @options[:html_part],
      tags: [@options[:tag]]
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

MailPlugger.plug_in('mandrill') do |api|
  api.delivery_options = %i[from to subject text_part html_part tag]
  api.delivery_settings = { return_response: true }
  api.client = MandrillApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'mandrill', tag: 'send_test'
  end
end
```

## Send Raw

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class MandrillApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['MANDRILL_API_KEY'] }
    @options = options
  end

  def deliver
    Mandrill::API.new(@settings[:api_key]).messages.send_raw(@options[:message_obj].to_s)
  end
end

MailPlugger.plug_in('mandrill') do |api|
  api.delivery_options = %i[message_obj]
  api.delivery_settings = { return_response: true }
  api.client = MandrillApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'mandrill'
  end
end
```
