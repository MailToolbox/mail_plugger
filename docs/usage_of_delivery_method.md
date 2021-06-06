# How to use MailPlugger::DeliveryMethod class

With this Class it can extract data from the `Mail::Message` object and send message based on the given configurations. We can add these options directly in the `new` method or we can use `MailPlugger.plug_in` method as well.

The `new` method parameter is a Hash where the keys are Symbols.

Hash parameters:
- `client` which should be a Class (It can be a Hash with this Class as well. In this case the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). This Class is a special Class which generates the data and calls the API to send the message. The Class should have an `initialize` and a `deliver` method.
- `delivery_options` which should be an Array with Symbols or Strings (It can be a Hash with this Array as well. In this case the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). It will search these options in the `Mail::Message` object like `from`, `to`, `cc`, `bcc`, `subject`, `body`, `text_part`, `html_part`, `attachments` or anything what we will add to this object. Also we can retrieve the `Mail::Message` object with `message_obj`.
- `delivery_settings` which should be a Hash. The Mail gem can use these settings like `{ return_response: true }` or we can add SMTP settings like `{ smtp_sttings: { address: 'smtp.server.com', port: 587, ... } }` (The keys are should be Symbols).
- `default_delivery_system` which should be a String or Symbol. This option is needed when we are not using `MailPlugger.plug_in` method, and `delivery_options`, `client` and `delivery_settings` are Hashes, and `delivery_system` is the key of the Hash, and `delivery_system` is not defined in the `Mail::Message` object. When `delivery_system` in the `Mail::Message` object is not defined then the `default_delivery_system` value is the key of those Hashes. When `default_delivery_system` is not defined then `default_delivery_system_get` method will return with the first key of `delivery_options`, `client` or `delivery_settings` Hash.

Examples:

## SMTP

We can add simple options to `MailPlugger::DeliveryMethod`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new(delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }).deliver!(message)
```

Or we can add these options into a Hash and set `default_delivery_system`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new(delivery_settings: { 'test_smtp_client' => { smtp_settings: { address: '127.0.0.1', port: 1025 } } }, default_delivery_system: 'test_smtp_client').deliver!(message)
```

Add `delivery_system` in the `Mail::Message` object (it will search this value in the given Hash). The `delivery_system` type in the `Mail::Message` object should match with the given key type of the Hash (if `delivery_system` is String then Hash key should String as well).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body', delivery_system: 'test_smtp_client')

MailPlugger::DeliveryMethod.new(delivery_settings: { 'test_smtp_client' => { smtp_settings: { address: '127.0.0.1', port: 1025 } } }).deliver!(message)
```

We can use `MailPlugger.plug_in` to add our configurations.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new.deliver!(message)
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

We can add simple options to `MailPlugger::DeliveryMethod`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], client: TestApiClientClass).deliver!(message)
```

Or we can add these options in Hash and set `default_delivery_system`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }, default_delivery_system: 'test_api_client').deliver!(message)
```

Add `delivery_system` in the `Mail::Message` object (it will search this value in the given Hash). The `delivery_system` type in the `Mail::Message` object should match with the given key type of the Hash (if `delivery_system` is String then Hash key should String as well).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body', delivery_system: 'test_api_client')

MailPlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }).deliver!(message)
```

If we are not adding `delivery_system` anywhere then it will use the first key of the Hash.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }).deliver!(message)
```

We can use `MailPlugger.plug_in` to add our configurations.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

MailPlugger::DeliveryMethod.new.deliver!(message)
```

If we are using `mail_plugger` gem in Ruby on Rails we don't have to do anything with this class. Rails will load this method automatically if we add this config `config.action_mailer.delivery_method = :mail_plugger` e.g. into the `config/application.rb`. Basically we should use `MailPlugger.plug_in` method to configure this delivery method.
