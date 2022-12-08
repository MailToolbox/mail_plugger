**Go To:**

- [How to use AWS SES API with MailPlugger in Ruby on Rails](#how-to-use-aws-ses-api-with-mailplugger-in-ruby-on-rails)
  - [Send Email](#send-email)
  - [Send Raw Email](#send-raw-email)


# How to use AWS SES API with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use mailer method which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Add `aws-sdk-ses` gem to the `Gemfile`.

```ruby
gem 'aws-sdk-ses'
```

Then run `bundle install` command to deploy the gem.

## Send Email

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class AwsSesApiClient
  def initialize(options = {})
    @credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @region = ENV['AWS_DEFAULT_REGION']
    @options = options
  end

  def deliver
    Aws::SES::Client.new(credentials: @credentials, region: @region).send_email(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      source: @options[:from].first,
      destination: {
        to_addresses: @options[:to]
      },
      message: {
        subject: {
          charset: 'UTF-8',
          data: @options[:subject]
        },
        body: {
          text: {
            charset: 'UTF-8',
            data: @options[:text_part]
          },
          html: {
            charset: 'UTF-8',
            data: @options[:html_part]
          }
        }
      },
      tags: [
        {
          name: @options[:message_obj].delivery_handler.to_s,
          value: @options[:tag]
        }
      ],
      configuration_set_name: @options[:configuration_set_name]
    }
  end
end

MailPlugger.plug_in('aws_ses') do |api|
  api.client = AwsSesApiClient
  api.delivery_options = %i[from to subject text_part html_part message_obj tag configuration_set_name]
  api.delivery_settings = { return_response: true }
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'aws_ses', tag: 'send_test', configuration_set_name: "#{Rails.env}_events_tracking"
  end
end
```

## Send Raw Email

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
class AwsSesApiClient
  def initialize(options = {})
    @credentials = Aws::Credentials.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'])
    @region = ENV['AWS_DEFAULT_REGION']
    @options = options
  end

  def deliver
    Aws::SES::Client.new(credentials: @credentials, region: @region).send_raw_email(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      raw_message: {
        data: @options[:message_obj].to_s
      },
      tags: [
        {
          name:  @options[:message_obj].delivery_handler.to_s,
          value: @options[:tag]
        }
      ],
      configuration_set_name: @options[:configuration_set_name]
    }
  end
end

MailPlugger.plug_in('aws_ses') do |api|
  api.client = AwsSesApiClient
  api.delivery_options = %i[message_obj tag configuration_set_name]
  api.delivery_settings = { return_response: true }
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'aws_ses', tag: 'send_test', configuration_set_name: "#{Rails.env}_events_tracking"
  end
end
```
