# How to use Postmark API with MailPlugger in Ruby on Rails

**Please note that these examples were not tested, but I believe it should work.**

Let's use the mailer method that was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Add the `postmark` gem to the `Gemfile`.

```ruby
gem 'postmark'
```

Then run the `bundle install` command to deploy the gem.

Change the API class and the `MailPlugger.plug_in` method in the `config/initializers/mail_plugger.rb` file.

```ruby
class PostmarkApiClient
  def initialize(options = {})
    @settings = { token: ENV['POSTMARK_TOKEN'] }
    @options = options
  end

  def deliver
    Postmark::ApiClient.new(@settings[:token]).deliver(generate_mail_hash)
  end

  private

  def generate_mail_hash
    {
      from: @options[:from].first,
      to: @options[:to],
      subject: @options[:subject],
      text_body: @options[:text_part],
      html_body: @options[:html_part],
      tag: @options[:tag]
    }
  end
end

MailPlugger.plug_in('postmark') do |api|
  api.client = PostmarkApiClient
  api.delivery_options = %i[from to subject text_part html_part tag]
  api.delivery_settings = { return_response: true }
end
```

Then modify the mailer method a little bit.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'postmark', tag: 'send_test'
  end
end
```
