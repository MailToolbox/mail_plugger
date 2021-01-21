# How to use FakePlugger in a Ruby script or IRB console

**This Class was made for development and testing purpose. Please do not use on production environment.**

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
  api.delivery_settings = { fake_plugger_debug: true, fake_plugger_raw_message: true }
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: {"test_api_client"=>TestApiClientClass}
#
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :body]}"
#
#==> @delivery_settings: {"test_api_client"=>{:fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}"
#
#==> @default_delivery_system: "test_api_client"
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: "test_api_client"
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {:fake_plugger_debug=>true, :fake_plugger_raw_message=>true}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:27:18 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046566b693a_f4886f4-486@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<TestApiClientClass:0x00007fad6c1c72f0 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}>

# or

MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { fake_plugger_response: { status: :ok } }
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
# => {:status=>:ok}

# or

MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { fake_plugger_response: { return_delivery_data: true } }
  api.client = TestApiClientClass
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
# => {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
```

Or we can use the `FakePlugger::DeliveryMethod` directly as well.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], client: TestApiClientClass, debug: true, raw_message: true).deliver!(message)
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:41:16 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <600468aca75ae_f9a76f43792c@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<TestApiClientClass:0x00007fb22d2302d0 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}>

# or

FakePlugger::DeliveryMethod.new(response: { status: :ok }).deliver!(message)
# => {:status=>:ok}

# or

FakePlugger::DeliveryMethod.new(delivery_options: %i[from to subject body], response: { return_delivery_data: true }).deliver!(message)
# => {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
```

Or add `FakePlugger::DeliveryMethod` to `mail.delivery_method`.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_options: %i[from to subject body], client: TestApiClientClass, debug: true, raw_message: true }
# => #<FakePlugger::DeliveryMethod:0x00007ffd1138ef30 @client=TestApiClientClass, @delivery_options=[:from, :to, :subject, :body], @delivery_settings=nil, @default_delivery_system=nil, @message=nil, @debug=true, @raw_message=true, @settings=nil, @response=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:53:02 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046b6e7357f_fcde6f4-4e5@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:53:02 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046b6e7357f_fcde6f4-4e5@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
```

Let's try to manipulate the response.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { response: { status: :ok } }
# => #<FakePlugger::DeliveryMethod:0x00007fe2b0c213a8 @client=nil, @delivery_options=nil, @delivery_settings=nil, @default_delivery_system=nil, @message=nil, @settings=nil, @debug=false, @raw_message=false, @response={:status=>:ok}>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
```

Let's add delivery settings to the delivery method.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_options: %i[from to subject body], client: TestApiClientClass, delivery_settings: { return_response: true } }
# => #<FakePlugger::DeliveryMethod:0x00007fb1859f5180 @client=TestApiClientClass, @delivery_options=[:from, :to, :subject, :body], @delivery_settings={:return_response=>true}, @default_delivery_system=nil, @message=nil, @delivery_system=nil, @settings={:return_response=>true}, @debug=false, @raw_message=false, @response=nil>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => #<TestApiClientClass:0x00007fb185b2dfe8 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}>

# if it returns with the client class then we can call the client's deliver method

mail.deliver!.deliver
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```

Let's try to manipulate the response and add delivery settings like above.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { return_response: true }, response: { status: :ok } }
# => #<FakePlugger::DeliveryMethod:0x00007fe2b20fa3d8 @client=nil, @delivery_options=nil, @delivery_settings={:return_response=>true}, @default_delivery_system=nil, @message=nil, @delivery_system=nil, @settings={:return_response=>true}, @debug=false, @raw_message=false, @response={:status=>:ok}>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => {:status=>:ok}
```

Let's use `MailPlugger.plug_in` method  with return response.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { return_response: true, fake_plugger_debug: true, fake_plugger_raw_message: true }
  api.client = TestApiClientClass
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007f84aea2e768 @client={"test_api_client"=>TestApiClientClass}, @delivery_options={"test_api_client"=>[:from, :to, :subject, :body]}, @delivery_settings={"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}, @default_delivery_system="test_api_client", @message=nil, @delivery_system="test_api_client", @settings={:return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}, @debug=true, @raw_message=true, @response=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:53:02 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046b6e7357f_fcde6f4-4e5@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:53:02 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046b6e7357f_fcde6f4-4e5@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# => #<TestApiClientClass:0x00007f84af91d490 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}>

# if it returns with the client class then we can call the client's deliver method

mail.deliver!.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]"
#
#==> @delivery_settings: nil"
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: nil
#
#==> delivery_options: [:from, :to, :subject, :body]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
#
#==> settings: {}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sun, 17 Jan 2021 17:53:02 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <60046b6e7357f_fcde6f4-4e5@server.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#=======================================================================
#
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body"}]}
# => {:response=>"OK"}
```

Let's use `MailPlugger.plug_in` method with return response and fake response.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { return_response: true, fake_plugger_response: { status: :ok } }
  api.client = TestApiClientClass
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007f8263a51f30 @client={"test_api_client"=>TestApiClientClass}, @delivery_options={"test_api_client"=>[:from, :to, :subject, :body]}, @delivery_settings={"test_api_client"=>{:return_response=>true, :fake_plugger_response=>{:status=>:ok}}}, @default_delivery_system="test_api_client", @message=nil, @delivery_system="test_api_client", @settings={:return_response=>true, :fake_plugger_response=>{:status=>:ok}}, @debug=false, @raw_message=false, @response={:status=>:ok}>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => {:status=>:ok}
```
