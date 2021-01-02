## Use MailPlugger in a Ruby script or IRB console

First you should be able to `require 'mail'` and `require 'mail_plugger'` to get started.

We need a class which will send the message in the right format via API.

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

We can use `MailPlugger.plug_in` to add our configurations.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

MailPlugger::DeliveryMethod.new.deliver!(message)
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```

Or we can use the `MailPlugger::DeliveryMethod` directly as well.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

MailPlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], client: TestApiClientClass).deliver!(message)
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```

Or add `MailPlugger::DeliveryMethod` to `mail.delivery_method`.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method MailPlugger::DeliveryMethod, { delivery_options: %i[from to subject body], client: TestApiClientClass }
# => #<MailPlugger::DeliveryMethod:0x00007fecbbb2ca00 @delivery_options=[:from, :to, :subject, :body], @client=TestApiClientClass, @default_delivery_system=nil, @delivery_settings=nil, @message=nil>

mail.deliver
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
```

Let's add delivery settings to the delivery method.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method MailPlugger::DeliveryMethod, { delivery_options: %i[from to subject body], client: TestApiClientClass, delivery_settings: { return_response: true } }
# => #<MailPlugger::DeliveryMethod:0x00007fecbb9e3630 @delivery_options=[:from, :to, :subject, :body], @client=TestApiClientClass, @default_delivery_system=nil, @delivery_settings={:return_response=>true}, @message=nil>

mail.deliver
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```

Let's use `MailPlugger.plug_in` method.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { return_response: true }
  api.client = TestApiClientClass
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method MailPlugger::DeliveryMethod
# => #<MailPlugger::DeliveryMethod:0x00007ffed930b8f0 @delivery_options={"test_api_client"=>[:from, :to, :subject, :body]}, @client={"test_api_client"=>TestApiClientClass}, @default_delivery_system="test_api_client", @delivery_settings={"test_api_client"=>{:return_response=>true}}, @message=nil>

mail.deliver
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => #<Mail::Message:1960, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# >>> settings: {:api_key=>"12345"}
# >>> options: {:from=>["from@example.com"], :to=>["to@example.com"], :subject=>"Test email", :body=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```
