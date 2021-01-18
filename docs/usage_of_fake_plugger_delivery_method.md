# How to use FakePlugger::DeliveryMethod class

**This Class was made for development and testing purpose. Please do not use on production environment.**

With this Class it can extract data from the `Mail::Message` object and mock send message based on the given configurations. We can add these options directly in the `new` method or we can use `MailPlugger.plug_in` method as well.

The `new` method parameter is a Hash where the keys are Symbols.

Hash parameters:
- `client` which should be a Class (It can be a Hash with this Class as well. In this case the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). This Class is a special Class which generates the data and calls the API to send the message. The Class should have an `initialize` and a `deliver` method.
- `delivery_options` which should be an Array with Symbols or Strings (It can be a Hash with this Array as well. In this case the key of the Hash is the `delivery_system` from the `Mail::Message` object or the `default_delivery_system`). It will search these options in the `Mail::Message` object like `from`, `to`, `cc`, `bcc`, `subject`, `body`, `text_part`, `html_part`, `attachments` or anything what we will add to this object. Also we can retrieve the `Mail::Message` object with `message_obj`.
- `delivery_settings` which should be a Hash. The Mail gem can use these settings like `{ return_response: true }` (The keys are should be Symbols). Also we can give configurations to the `FakePlugger::DeliveryMethod` like `{ fake_plugger_debug: true }`.
- `default_delivery_system` which should be a String or Symbol. This option is needed when `delivery_options` and `client` are Hashes. When `delivery_system` in the `Mail::Message` object is not defined then the `default_delivery_system` value is the key of those Hashes. When `default_delivery_system` is not defined then `default_delivery_system_get` will return with the first key of `delivery_options` or `client` Hash.
- `debug` which should be a Boolean. If this parameter is true then it will prints out debug informations like variable values and output of some methods. If we are using `MailPlugger.plug_in` method then we can set this value to add `fake_plugger_debug: true` into the `delivery_settings` Hash.
- `raw_message` which should be a Boolean. If this parameter is true then it will prints out the raw message content. If we are using `MailPlugger.plug_in` method then we can set this value to add `fake_plugger_raw_message: true` into the `delivery_settings` Hash.
- `response` which returns back with the give value. But if this parameter is `nil` then it will extract those information from the `Mail::Message` object which was provided in the `delivery_options`. After that it generates a hash with these data and returns with the provided `client` Class which has a `deliver` method, but it won't call the `deliver` method. If the `response` parameter is a Hash with `return_message_obj: true` then it will retrun with the `Mail::Message` object. If we are using `MailPlugger.plug_in` method then we can set this value to add e.g. `fake_plugger_response: { status: :ok }` into the `delivery_settings` Hash.

Examples:

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

FakePlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], client: TestApiClientClass, debug: true, raw_message: true).deliver!(message)
```

Or we can add these options in Hash and set `default_delivery_system`.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }, default_delivery_system: 'test_api_client', debug: true, raw_message: true).deliver!(message)
```

Add `delivery_system` in the `Mail::Message` object (it will search this value in the given Hash). The `delivery_system` type in the `Mail::Message` object should match with the given key type of the Hash (if `delivery_system` is String then Hash key should String as well).

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body', delivery_system: 'test_api_client')

FakePlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }, debug: true, raw_message: true).deliver!(message)
```

If we are not adding `delivery_system` anywhere then it will use the first key of the Hash.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_options: { 'test_api_client' => %i[from to subject body] }, client: { 'test_api_client' => TestApiClientClass }, debug: true, raw_message: true).deliver!(message)
```

We can manipulate the response to get back anything what we want.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(response: { status: :ok }).deliver!(message)
```

It can returns with the `Mail::Message` object.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(response: { return_message_obj: :true }).deliver!(message)
```

Without the response parameter it returns back with `client` object so we can force delivery if we would like to.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], client: TestApiClientClass).deliver!(message).deliver
```

We can use `MailPlugger.plug_in` to add our configurations.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { fake_plugger_debug: true, fake_plugger_raw_message: true }
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')

FakePlugger::DeliveryMethod.new.deliver!(message)
```

If we are using `mail_plugger` gem in Ruby on Rails we don't have to do anything with this class. Rails will load this method automatically if we add this config `config.action_mailer.delivery_method = :fake_plugger` e.g. into the `config/environments/development.rb`. Basically we should use `MailPlugger.plug_in` method to configure this delivery method.
