**Go To:**

- [How to use MailPlugger.plug_in method](#how-to-use-mailpluggerplug_in-method)
  - [SMTP](#smtp)
  - [API](#api)


# How to use MailPlugger.plug_in method

With the `plug_in` method, we can add configurations for the delivery method.

It has a parameter that calls to `delivery_system`. This parameter contains the name of the delivery system like `aws_ses`, `sparkpost`, `sendgrid`, etc. Basically, it can be anything that helps to identify this delivery system. The `delivery_system` can be either String or Symbol, but the `delivery_system` type should match with the type of the `delivery_system` parameter of the `Mail::Message` object (if `delivery_system` is String, then the `delivery_system` parameter in the `Mail::Message` object should be String as well).

It can accept 4 configurations:
- `client` which should be a Class. This Class is a special Class that generates the data and calls the API to send the message. The Class should have an `initialize` and a `deliver` method.
- `default_delivery_options` which should be a Hash. All messages that we send with the `delivery_system` will get these options defined in this Hash, but if an option is defined in the `Mail::Message` object as well, then it will override the value of the default option.
- `delivery_options` which should be an Array with Symbols or Strings. It will search these options in the `Mail::Message` object, like `from`, `to`, `cc`, `bcc`, `subject`, `body`, `text_part`, `html_part`, `attachments`, or anything that we will add to this object. Also, we can retrieve the `Mail::Message` object with `message_obj`.
- `delivery_settings` which should be a Hash. The Mail gem can use these settings like `{ return_response: true }`, or we can add SMTP settings like `{ smtp_settings: { address: 'smtp.server.com', port: 587, ... } }`.

Example:

## SMTP

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: {
      address: 'smtp.server.com',
      port: 587,
      domain: 'test.domain.com',
      enable_starttls_auto: true,
      user_name: 'test_user',
      password: '1234',
      authentication: :plain
    }
  }
end
```

## API

```ruby
# NOTE: This is just an example for testing...
class TestApiClientClass
  def initialize(options = {})
    @settings = { api_key: '12345' }
    @options = options
  end

  def deliver
    # e.g. API.new(@settings).client.post(generate_mail_hash)
    puts " >>> settings: #{@settings.inspect}"
    puts " >>> options: #{@options.inspect}"
    puts " >>> generate_mail_hash: #{generate_mail_hash.inspect}"
    { response: 'OK' }
  end

  private

  def generate_mail_hash
    {
      to: generate_recipients,
      from: {
        email: @options[:from].first
      },
      subject: @options[:subject],
      content: [
        {
          type: 'text/plain',
          value: @options[:body]
        }
      ],
      tags: [
        @options[:tag]
      ]
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

MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.default_delivery_options = { tag: 'test_tag' }
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { return_response: true }
end
```
