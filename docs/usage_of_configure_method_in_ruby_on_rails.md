**Go To:**

- [How to use MailPlugger.configure method in Ruby on Rails](#how-to-use-mailpluggerconfigure-method-in-ruby-on-rails)
  - [Default delivery system](#default-delivery-system)
  - [Sending method](#sending-method)
    - [default_delivery_system](#default_delivery_system)
    - [plugged_in_first](#plugged_in_first)
    - [random](#random)
    - [round_robin](#round_robin)


# How to use MailPlugger.configure method in Ruby on Rails

Let's modify the configuration that was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md).

Change the `MailPlugger.plug_in` methods in the `config/initializers/mail_plugger.rb` file.

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
end

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
    { response: 'Message sent via API' }
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
          value: @options[:text_part]
        },
        {
          type: 'text/html; charset=UTF-8',
          value: @options[:html_part]
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
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
end
```

## Default delivery system

Add `MailPlugger.configure` in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.configure do |config|
  config.default_delivery_system = 'test_api_client'
end
```

Then change the `app/mailers/test_mailer.rb` file and define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'test_smtp_client'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:15:24 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 31.6ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we do not define any `delivery_system`, then it will use the `default_delivery_system`, defined with the `MailPlugger.configure` method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 19.4ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

## Sending method

### default_delivery_system

Same behavior as above, just we are defining both `default_delivery_system` and `sending_method` as well.

```ruby
MailPlugger.configure do |config|
  config.default_delivery_system = 'test_api_client'
  config.sending_method = 'default_delivery_system'
end
```

### plugged_in_first

Change the `MailPlugger.configure` in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.configure do |config|
  config.sending_method = 'plugged_in_first'
end
```

Then change the `app/mailers/test_mailer.rb` file and define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'test_smtp_client'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:18:48 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 31.6ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we do not define any `delivery_system`, then it will use the first plugged-in delivery system, defined with the `MailPlugger.plug_in` method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:19:40 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 19.4ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:19:41 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

### random

Change the `MailPlugger.configure` in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.configure do |config|
  config.sending_method = 'random'
end
```

Then change the `app/mailers/test_mailer.rb` file and define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'test_smtp_client'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:22:32 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 31.6ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we do not define any `delivery_system`, then it will choose randomly between the defined delivery systems.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:24:21 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:24:22 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

### round_robin

Change the `MailPlugger.configure` in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.configure do |config|
  config.sending_method = 'round_robin'
end
```

Then change the `app/mailers/test_mailer.rb` file and define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'test_smtp_client'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:26:40 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 31.6ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we do not define any `delivery_system`, then it will choose delivery systems in circular order.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:28:13 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 08 Dec 2022 16:28:15 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.7ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```
