# How to combine SMTP and API delivery systems in Ruby on Rails

Let's modify the configuration which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_more_smtp_delivery_systems_in_ruby_on_rails.md).

Replace a SMTP client with an API client in `config/initializers/mail_plugger.rb`.

## When SMTP client defined first

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
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
  api.client = TestApiClientClass
end
```

Then change `app/mailers/test_mailer.rb` file.

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

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 37.5ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:50:02 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86d8a82fa2_cf45ec185171d@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86d8a7f906_cf45ec185161d"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 34.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

In the `app/mailers/test_mailer.rb` file we can use the Rails default option as well to define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_smtp_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 29.2ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:53:53 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86e71ed0d8_d0a8ec18155d0@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86e71eb82b_d0a8ec18154e7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test2: processed outbound mail in 16.7ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:53:55 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86e73c7b76_d0a8ec18157f0@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86e73c3f28_d0a8ec1815671"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>
```

Or we can use default, but override it in the method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_smtp_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 31.3ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:55:37 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86ed9563c6_d160ec18227b1@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86ed954a22_d160ec1822622"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 16.7ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we are not define any `delivey_system` then it will use the first defined one with `MailPlugger.plug_in` method.

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

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 30.9ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:57:33 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86f4d15edf_d22eec1876088@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86f4d14881_d22eec18759b5"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 19.4ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:57:36 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86f5060fab_d22eec187629d@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86f505e9bb_d22eec1876187"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Or we can just define `delivery_system` where we would like to use the other one.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.2ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 46.0ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 07:59:29 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b86fc1a2058_d2f6ec1836324@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b86fc1a03a6_d2f6ec18362a0"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 19.2ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

## When API client defined first

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
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
  api.client = TestApiClientClass
end

MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
end
```

Then change `app/mailers/test_mailer.rb` file.

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

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 08:05:52 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871405d05c_d557ec187090@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871405b6b9_d557ec1869a7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

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

In the `app/mailers/test_mailer.rb` file we can use the Rails default option as well to define `delivery_system`.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_smtp_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 36.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 08:07:56 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871bc8d3e1_d631ec18886ac@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871bc8b4d3_d631ec188851"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 18.3ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 08:07:58 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b871be40a6_d631ec188886d@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b871be1773_d631ec18887a9"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>
```

Or we can use default, but override it in the method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_smtp_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_api_client'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 37.1ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 08:10:12 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b872441084f_d72bec181736a@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b87244e89a_d72bec1817275"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.5ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 20.4ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Or if we are not define any `delivey_system` then it will use the first defined one with `MailPlugger.plug_in` method.

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

In the `rails console` we can try it out.

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

Or we can just define `delivery_system` where we would like to use the other one.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', delivery_system: 'test_smtp_client'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.7ms)
#TestMailer#send_test: processed outbound mail in 37.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Thu, 03 Jun 2021 08:17:06 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b873e2adf38_d9efec1848512@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b873e2ac07e_d9efec18484ef"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.5ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 21.3ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```
