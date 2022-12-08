# How to use MailPlugger.configure method

With `configure` method, we can add configurations for the MailPlugger.

It can accept 2 configurations:
- `default_delivery_system` which can be either String or Symbol, but the `default_delivery_system` type should match with the type of the `delivery_system`, defined in `MailPlugger.plug_in` method. This option is not necessarily require the `sending_method` option, but if we are using it, then the sending method should equal with `default_delivery_system`.
- `sending_method` which can be either String or Symbol. We can define how to send the messages. The `plugged_in_first`, `random`, and `round_robin` sending methods are ignoring the `default_delivery_system` option.
There are 4 type of sending methods:
  - `default_delivery_system` will use the configured `default_delivery_system` to send the message, but if the `default_delivery_system` is not configured, then it will use the `plugged_in_first` sending method.
  - `plugged_in_first` will use the first delivery system, which we plugged in with `MailPlugger.plug_in` method. This is the default behavior.
  - `random` will choose randomly between delivery systems. At least two plugged in delivery system needed.
  - `round_robin` will choose delivery systems in circular order. At least two plugged in delivery system needed.

If we define `delivery_system` in the `Mail::Message` object, then it will use the delivery system defined in the `Mail::Message` object.
There is a limitation here. For example, if we selects `round_robin` as a sending method, and we defines `delivery_system` in the `Mail::Message` object, then it cannot choose delivery systems equally because it chooses a delivery system every single time, but we override it.

Example:

```ruby
MailPlugger.configure do |config|
  config.default_delivery_system = 'test_api_client'
end

# or

MailPlugger.configure do |config|
  config.default_delivery_system = 'test_api_client'
  config.sending_method = 'default_delivery_system'
end

# or

MailPlugger.configure do |config|
  config.sending_method = 'random'
end
```
