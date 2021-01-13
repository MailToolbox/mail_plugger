# How to use MailPlugger.plug_in method

With `plug_in` method we can add configurations for the delivery method.

It has a parameter which calls to `delivery_system`. This parameter is a name of the delivery system like `aws_ses`, `sparkpost`, `sendgrid`, etc. Basically it can be anything which helps to identify this delivery system. The `delivery_system` can be either String or Symbol, but the `delivery_system` type should match with the type of the `Mail::Message` object `delivery_system` parameter (if `delivery_system` is String then in the `Mail::Message` object `delivery_system` parameter should be String as well).

It can accept 3 configurations:
- `client` which should be a Class. This Class is a special class which generates the data and calls the API to send the message.
- `delivery_options` which should be an Array with Symbols or Strings. It will search these options in the `Mail::Message` object like `from`, `to`, `cc`, `bcc`, `subject`, `body`, `text_part`, `html_part`, `attachments` or anything what we will add to this object. Also we can retrieve the `Mail::Message` object with `message_obj`.
- `delivery_settings` which should be a Hash. The Mail gem can use these settings like `{ return_response: true }` (The keys are should be Symbols).

Example:

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

MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { return_response: true }
  api.client = TestApiClientClass
end
```
