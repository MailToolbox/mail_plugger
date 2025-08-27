**Go To:**

- [How to use FakePlugger::DeliveryMethod class](#how-to-use-fakepluggerdeliverymethod-class)
  - [SMTP](#smtp)
  - [API](#api)


# How to use FakePlugger::DeliveryMethod class

**This Class was made for development and testing purposes. Please do not use it in the production environment.**

With this Class, it can extract data from the `Mail::Message` object and mock the message sending based on the given configurations. We can add these options directly in the `new` method, or we can use the `MailPlugger.plug_in` method as well.

The `new` method parameter is a Hash where the keys are Symbols.

Hash parameters:
- `client` which should be a Class (It can be a Hash with this Class as well. In this case, the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). This Class is a special Class that generates the data and calls the API to send the message. The Class should have an `initialize` and a `deliver` method.
- `delivery_options` which should be an Array with Symbols or Strings (It can be a Hash with this Array as well. In this case, the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). It will search these options in the `Mail::Message` object, like `from`, `to`, `cc`, `bcc`, `subject`, `body`, `text_part`, `html_part`, `attachments`, or anything what we will add to this object. Also, we can retrieve the `Mail::Message` object with `message_obj`.
- `delivery_settings` which should be a Hash. The Mail gem can use these settings like `{ return_response: true }`, or we can add SMTP settings like `{ smtp_settings: { address: 'smtp.server.com', port: 587, ... } }` (The keys should be Symbols). Also, we can give configurations to the `FakePlugger::DeliveryMethod` like `{ fake_plugger_debug: true }`.
- `default_delivery_system` which should be a String or Symbol. This option is needed when we are not using the `MailPlugger.plug_in` method, and `delivery_options`, `client`, and `delivery_settings` are Hashes, and `delivery_system` is the key of the Hash, and `delivery_system` is not defined in the `Mail::Message` object. When the `delivery_system` in the `Mail::Message` object is not defined, then the `default_delivery_system` value is the key of those Hashes. When `default_delivery_system` is not defined, then `default_delivery_system_get` method will return with the first key of `delivery_options`, `client`, or `delivery_settings` Hash.
- `debug` which should be a Boolean. The default value is `false`. If this parameter is `true`, then it will print out debug information like variable values and output of some methods. If we are using the `MailPlugger.plug_in` method, then we can set this value to add `fake_plugger_debug: true` into the `delivery_settings` Hash.
- `raw_message` which should be a Boolean. The default value is `false`. If this parameter is `true`, then it will print out the raw message content. If we are using the `MailPlugger.plug_in` method, then we can set this value to add `fake_plugger_raw_message: true` into the `delivery_settings` Hash.
- `response` which returns with the given value. But if this parameter is `nil`, then it will extract this information from the `Mail::Message` object which was provided in the `delivery_options`. After that, it generates a hash with the data and returns with the provided `client` Class, which has a `deliver` method, but it won't call the `deliver` method. If the `response` parameter is a Hash with `return_delivery_data: true`, then it will return with the extracted delivery data. If we are using the `MailPlugger.plug_in` method, then we can set this value to add e.g. `fake_plugger_response: { status: :ok }` into the `delivery_settings` Hash.
- `use_mail_grabber` which should be a Boolean. The default value is `false`. If this parameter is `true`, then it will store the message in a database that **[MailGrabber](https://github.com/MailToolbox/mail_grabber)** can read. If we are using the `MailPlugger.plug_in` method, then we can set this value to add `fake_plugger_use_mail_grabber: true` into the `delivery_settings` Hash. **This option requires the [MailGrabber](https://github.com/MailToolbox/mail_grabber) gem to be installed.**

Examples:

## SMTP

We can add simple options to `FakePlugger::DeliveryMethod`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }, debug: true, raw_message: true).deliver!(message)
```

Or we can add these options in a Hash and set `default_delivery_system`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_settings: { 'test_smtp_client' => { smtp_settings: { address: '127.0.0.1', port: 1025 } } }, default_delivery_system: 'test_smtp_client', debug: true, raw_message: true).deliver!(message)
```

Add `delivery_system` in the `Mail::Message` object (it will search this value in the given Hash). The `delivery_system` type in the `Mail::Message` object should match with the given key type of the Hash (if `delivery_system` is a String then the Hash key should be a String as well).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body', delivery_system: 'test_smtp_client')

FakePlugger::DeliveryMethod.new(delivery_settings: { 'test_smtp_client' => { smtp_settings: { address: '127.0.0.1', port: 1025 } } }, debug: true, raw_message: true).deliver!(message)
```

If we are not adding `delivery_system` anywhere, then it will use the first key of the Hash.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_settings: { 'test_smtp_client' => { smtp_settings: { address: '127.0.0.1', port: 1025 } } }, debug: true, raw_message: true).deliver!(message)
```

We can manipulate the response to get back anything that we want.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(response: 'OK').deliver!(message)
```

Without the response parameter, it returns with a `message` object, and then we can force delivery if we would like to.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }).deliver!(message).deliver
```

If we installed the **[MailGrabber](https://github.com/MailToolbox/mail_grabber#usage)** gem, then we can store messages, which **[MailGrabber](https://github.com/MailToolbox/mail_grabber#usage)** will show us (please follow the link to check how to do that).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }, use_mail_grabber: true).deliver!(message)
```

We can use the `MailPlugger.plug_in` method to add our configurations.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    fake_plugger_debug: true,
    fake_plugger_raw_message: true,
    fake_plugger_use_mail_grabber: true
  }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new.deliver!(message)
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
```

We can add simple options to `FakePlugger::DeliveryMethod`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(client: TestApiClientClass, delivery_options: %i[from to subject body], debug: true, raw_message: true).deliver!(message)
```

Or we can add these options in Hash and set `default_delivery_system`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(client: { 'test_api_client' => TestApiClientClass }, delivery_options: { 'test_api_client' => %i[from to subject body] }, default_delivery_system: 'test_api_client', debug: true, raw_message: true).deliver!(message)
```

Add `delivery_system` in the `Mail::Message` object (it will search this value in the given Hash). The `delivery_system` type in the `Mail::Message` object should match with the given key type of the Hash (if `delivery_system` is a String then the Hash key should be a String as well).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body', delivery_system: 'test_api_client')

FakePlugger::DeliveryMethod.new(client: { 'test_api_client' => TestApiClientClass }, delivery_options: { 'test_api_client' => %i[from to subject body] }, debug: true, raw_message: true).deliver!(message)
```

If we are not adding `delivery_system` anywhere, then it will use the first key of the Hash.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(client: { 'test_api_client' => TestApiClientClass }, delivery_options: { 'test_api_client' => %i[from to subject body] }, debug: true, raw_message: true).deliver!(message)
```

We can manipulate the response to get back anything what we want.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(response: { status: :ok }).deliver!(message)
```

It can return with the extracted delivery data.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], response: { return_delivery_data: true }).deliver!(message)
```

Without the response parameter, it returns with the `client` object, then we can force delivery if we would like to.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(client: TestApiClientClass, delivery_options: %i[from to subject body]).deliver!(message).deliver
```

If we installed **[MailGrabber](https://github.com/MailToolbox/mail_grabber#usage)** gem, then we can store messages, which **[MailGrabber](https://github.com/MailToolbox/mail_grabber#usage)** will show us (please follow the link to check how to do that).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(client: TestApiClientClass, delivery_options: %i[from to subject body], use_mail_grabber: true).deliver!(message)
```

We can use the `MailPlugger.plug_in` method to add our configurations.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = {
    fake_plugger_debug: true,
    fake_plugger_raw_message: true,
    fake_plugger_use_mail_grabber: true
  }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new.deliver!(message)
```

If we are using the `mail_plugger` gem in Ruby on Rails, we don't have to do anything with this class. Rails will load this class automatically if we add this config `config.action_mailer.delivery_method = :fake_plugger` e.g. into the `config/environments/development.rb` file. Basically, we should use `MailPlugger.plug_in` method to configure this delivery method.
