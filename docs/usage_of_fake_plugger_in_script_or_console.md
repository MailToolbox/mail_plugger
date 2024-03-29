**Go To:**

- [How to use FakePlugger in a Ruby script or IRB console](#how-to-use-fakeplugger-in-a-ruby-script-or-irb-console)
  - [SMTP](#smtp)
  - [API](#api)


# How to use FakePlugger in a Ruby script or IRB console

**This Class was made for development and testing purpose. Please do not use on production environment.**

First, you should be able to `require 'mail'` and `require 'mail_plugger'` to get started.

## SMTP

We can use `MailPlugger.plug_in` to add our configurations.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    fake_plugger_debug: true,
    fake_plugger_raw_message: true
  }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: "test_smtp_client"
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, #<To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: "test_smtp_client"
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 14:23:24 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb6cbcc5e38_2a3f7087664f@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 14:23:24 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb6cbcc5e38_2a3f7087664f@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

# or

MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    fake_plugger_response: 'OK'
  }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
# => "OK"
```

Or we can use the `FakePlugger::DeliveryMethod` directly as well.

```ruby
message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new(delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }, debug: true, raw_message: true).deliver!(message)
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: nil
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 14:32:18 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb6ed2adfa_2db17085174e@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 14:32:18 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb6ed2adfa_2db17085174e@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

# or

FakePlugger::DeliveryMethod.new(response: 'OK').deliver!(message)
# => "OK"
```

Or add `FakePlugger::DeliveryMethod` to `mail.delivery_method`.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }, debug: true, raw_message: true }
# => #<FakePlugger::DeliveryMethod:0x00007ffad5c76e10 @client=nil, @delivery_options=nil, @delivery_settings={:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=true, @raw_message=true, @response=nil, @use_mail_grabber=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: nil
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 14:38:25 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb7041bc724_2ed0708-498@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 14:38:25 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb7041bc724_2ed0708-498@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

# or

# if you call mail.deliver twice, then it will send the email, so set delivery_method again

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 } }, debug: true, raw_message: true }
# => #<FakePlugger::DeliveryMethod:0x00007f92fdbebd50 @client=nil, @delivery_options=nil, @delivery_settings={:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=true, @raw_message=true, @response=nil, @use_mail_grabber=nil>

mail.deliver!
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: nil
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: nil
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 14:56:50 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb74924412d_36027083464a@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 14:56:50 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb74924412d_36027083464a@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>
```

Let's try to manipulate the response.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { response: 'OK' }
# => #<FakePlugger::DeliveryMethod:0x00007fccf93f4f08 @client=nil, @delivery_options=nil, @delivery_settings=nil, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response="OK", @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

# this time it won't overwrite the delivery method

mail.deliver!
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
```

Let's add `return_response: true` to the delivery settings.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 }, return_response: true } }
# => #<FakePlugger::DeliveryMethod:0x00007fe7f3d36d68 @client=nil, @delivery_options=nil, @delivery_settings={:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

# if you call mail.deliver twice, then it will send the email, so set delivery_method again

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 }, return_response: true } }
# => #<FakePlugger::DeliveryMethod:0x00007fe7f3abd5c8 @client=nil, @delivery_options=nil, @delivery_settings={:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver!
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

mail.deliver!
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 15:14:40 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb78c033c63_390e70834920@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>
```

Let's try to manipulate the response and add `return_response: true` like above.

```ruby
mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod, { delivery_settings: { smtp_settings: { address: '127.0.0.1', port: 1025 }, return_response: true }, response: 'OK' }
# => #<FakePlugger::DeliveryMethod:0x00007fa1c646d560 @client=nil, @delivery_options=nil, @delivery_settings={:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response="OK", @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

# this time it won't overwrite the delivery method

mail.deliver!
# => "OK"
```

Let's use `MailPlugger.plug_in` method  with return response.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true,
    fake_plugger_debug: true,
    fake_plugger_raw_message: true
  }
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007f9a2a442660 @client=nil, @delivery_options=nil, @delivery_settings={"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=["test_smtp_client"], @rotatable_delivery_systems=#<Enumerator: ["test_smtp_client"]:cycle>, @sending_method=nil, @default_delivery_system="test_smtp_client", @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: "test_smtp_client"
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: "test_smtp_client"
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 15:27:15 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 15:27:15 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

# or

# if you call mail.deliver twice, then it will send the email, so set delivery_method again

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007f9a2a62c610 @client=nil, @delivery_options=nil, @delivery_settings={"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=["test_smtp_client"], @rotatable_delivery_systems=#<Enumerator: ["test_smtp_client"]:cycle>, @sending_method=nil, @default_delivery_system="test_smtp_client", @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver!
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}
#
#==> @passed_default_delivery_system: nil
#
#==> @sending_method: nil
#
#==> @default_delivery_system: "test_smtp_client"
#
#==> @message: #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 15:27:15 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: "test_smtp_client"
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}
#
#=======================================================================
#
#
#============================ Mail::Message ============================
#
#Date: Sat, 05 Jun 2021 15:27:15 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>
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
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 15:27:15 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>

mail.deliver!
# => #<Mail::Message:1880, Multipart: false, Headers: <Date: Sat, 05 Jun 2021 15:27:15 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bb7bb39769a_3f5c708-418@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: text/plain>, <Content-Transfer-Encoding: 7bit>>
```

Let's use `MailPlugger.plug_in` method with return response and fake response.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true,
    fake_plugger_response: 'OK'
  }
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007fd0893569f0 @client=nil, @delivery_options=nil, @delivery_settings={"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_response=>"OK"}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=["test_smtp_client"], @rotatable_delivery_systems=#<Enumerator: ["test_smtp_client"]:cycle>, @sending_method=nil, @default_delivery_system="test_smtp_client", @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1880, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

# this time it won't overwrite the delivery method

mail.deliver!
# => "OK"
```

## API

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
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = {
    fake_plugger_debug: true,
    fake_plugger_raw_message: true
  }
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
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :body]}
#
#==> @delivery_settings: {"test_api_client"=>{:fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { fake_plugger_response: { status: :ok } }
end

message = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

FakePlugger::DeliveryMethod.new.deliver!(message)
# => {:status=>:ok}

# or

MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = { fake_plugger_response: { return_delivery_data: true } }
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
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
# => #<FakePlugger::DeliveryMethod:0x00007fd4b316f370 @client=TestApiClientClass, @delivery_options=[:from, :to, :subject, :body], @delivery_settings=nil, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=true, @raw_message=true, @response=nil, @use_mail_grabber=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
# => #<FakePlugger::DeliveryMethod:0x00007fd4b40a9b88 @client=nil, @delivery_options=nil, @delivery_settings=nil, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response={:status=>:ok}, @use_mail_grabber=nil>

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
# => #<FakePlugger::DeliveryMethod:0x00007fd4b3b5ada8 @client=TestApiClientClass, @delivery_options=[:from, :to, :subject, :body], @delivery_settings={:return_response=>true}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => #<TestApiClientClass:0x00007fb185b2dfe8 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "body"=>"Test email body"}>

# if it returns with the client class, then we can call the client's deliver method

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
# => #<FakePlugger::DeliveryMethod:0x00007fd4b40b9e20 @client=nil, @delivery_options=nil, @delivery_settings={:return_response=>true}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=nil, @rotatable_delivery_systems=nil, @sending_method=nil, @default_delivery_system=nil, @message=nil, @debug=nil, @raw_message=nil, @response={:status=>:ok}, @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => {:status=>:ok}
```

Let's use `MailPlugger.plug_in` method  with return response.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = {
    return_response: true,
    fake_plugger_debug: true,
    fake_plugger_raw_message: true
  }
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007fd4b39a7448 @client={"test_api_client"=>TestApiClientClass}, @delivery_options={"test_api_client"=>[:from, :to, :subject, :body]}, @delivery_settings={"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true, :fake_plugger_raw_message=>true}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=["test_api_client"], @rotatable_delivery_systems=#<Enumerator: ["test_api_client"]:cycle>, @sending_method=nil, @default_delivery_system="test_api_client", @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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

# if it returns with the client class, then we can call the client's deliver method

mail.deliver!.deliver
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: TestApiClientClass
#
#==> @delivery_options: [:from, :to, :subject, :body]
#
#==> @delivery_settings: nil
#
#==> @passed_default_delivery_system: nil
#
#==> @default_delivery_options: nil
#
#==> @sending_method: nil
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
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject body]
  api.delivery_settings = {
    return_response: true,
    fake_plugger_response: { status: :ok }
  }
end

mail = Mail.new(from: 'from@example.com', to: 'to@example.com', subject: 'Test email', body: 'Test email body')
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Tes...

mail.delivery_method FakePlugger::DeliveryMethod
# => #<FakePlugger::DeliveryMethod:0x00007feb0a2ec668 @client={"test_api_client"=>TestApiClientClass}, @delivery_options={"test_api_client"=>[:from, :to, :subject, :body]}, @delivery_settings={"test_api_client"=>{:return_response=>true, :fake_plugger_response=>{:status=>:ok}}}, @passed_default_delivery_system=nil, @default_delivery_options=nil, @delivery_systems=["test_api_client"], @rotatable_delivery_systems=#<Enumerator: ["test_api_client"]:cycle>, @sending_method=nil, @default_delivery_system="test_api_client", @message=nil, @debug=nil, @raw_message=nil, @response=nil, @use_mail_grabber=nil>

mail.deliver
# => #<Mail::Message:1860, Multipart: false, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>>

# or

mail.deliver!
# => {:status=>:ok}
```
