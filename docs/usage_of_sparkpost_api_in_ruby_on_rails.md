# How to use SparkPost API with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use mailer method which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Add `simple_spark` gem to the `Gemfile`.

```ruby
gem 'simple_spark'
```

Then run `bundle install` command to deploy the gem.

## Send Inline Content

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class SparkPostApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['SPARKPOST_API_KEY'] }
    @options = options
  end

  def deliver
    SimpleSpark::Client.new(@settings).transmissions.create(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      options: @options[:options],
      campaign_id: @options[:tag],
      content: {
        from: {
          email: @options[:from].first
        },
        subject: @options[:subject],
        text: @options[:text_part],
        html: @options[:html_part]
      },
      metadata: @options[:metadata],
      recipients: generate_recipients
    }
  end

  def generate_recipients
    @options[:to].map do |to|
      {
        address: {
          email: to
        },
        tags: [
          @options[:tag]
        ],
      }
    end
  end
end

MailPlugger.plug_in('sparkpost') do |api|
  api.delivery_options = %i[from to subject text_part html_part options tag metadata]
  api.delivery_settings = { return_response: true }
  api.client = SparkPostApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'sparkpost', tag: 'send_test', options: { open_tracking: true, click_tracking: false, transactional: true }, metadata: { website: 'testwebsite' }
  end
end
```

## Send RFC822 Content

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class SparkPostApiClient
  def initialize(options = {})
    @settings = { api_key: ENV['SPARKPOST_API_KEY'] }
    @options = options
  end

  def deliver
    SimpleSpark::Client.new(@settings).transmissions.create(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      options: @options[:options],
      campaign_id: @options[:tag],
      content: {
        email_rfc822: @options[:message_obj].to_s
      },
      metadata: @options[:metadata],
      recipients: generate_recipients
    }
  end

  def generate_recipients
    @options[:to].map do |to|
      {
        address: {
          email: to
        },
        tags: [
          @options[:tag]
        ],
      }
    end
  end
end

MailPlugger.plug_in('sparkpost') do |api|
  api.delivery_options = %i[to options message_obj tag metadata]
  api.delivery_settings = { return_response: true }
  api.client = SparkPostApiClient
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'sparkpost', tag: 'send_test', options: { open_tracking: true, click_tracking: false, transactional: true }, metadata: { website: 'testwebsite' }
  end
end
```
