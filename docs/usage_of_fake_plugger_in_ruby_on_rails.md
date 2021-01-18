# How to use FakePlugger in Ruby on Rails

**This Class was made for development and testing purpose. Please do not use on production environment.**

After to add `mail_plugger` gem and the gem of API of the mail provider, create `config/initializers/mail_plugger.rb` file and add something similar.

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
  api.client = TestApiClientClass
end
```

Then change `config/application.rb` file.

```ruby
config.action_mailer.delivery_method = :mail_plugger
```

Also change e.g. `config/environments/test.rb` file.

```ruby
config.action_mailer.delivery_method = :fake_plugger
```

So now we should add a mailer method. Let's create `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Then we should add views (the body) of this email, so create `app/views/test_mailer/send_test.html.erb`

```erb
<p>Test email body</p>
```

and `app/views/test_mailer/send_test.text.erb`.

```erb
Test email body
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 18.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> #<Mail::Message:61140, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_600526bddc121_15e86ebc839b"; charset=UTF-8>>
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 20.9ms
#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's add delivery settings as well in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
  api.client = TestApiClientClass
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 18.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"OK"}
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 20.9ms
# => #<TestApiClientClass:0x00007ff1c88e2c60 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}>

# if it returns with the client class then we can call the client's deliver method

TestMailer.send_test.deliver_now!.deliver
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 18.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"OK"}
```

Let's add debug option as well in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true, fake_plugger_debug: true }
  api.client = TestApiClientClass
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 18.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"OK"}
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: {"test_api_client"=>TestApiClientClass}
#
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :text_part, :html_part]}"
#
#==> @delivery_settings: {"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true}}"
#
#==> @default_delivery_system: "test_api_client"
#
#==> @message: #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: "test_api_client"
#
#==> delivery_options: [:from, :to, :subject, :text_part, :html_part]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
#
#==> settings: {:return_response=>true, :fake_plugger_debug=>true}
#
#=======================================================================
#
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 20.9ms
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @client: {"test_api_client"=>TestApiClientClass}
#
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :text_part, :html_part]}"
#
#==> @delivery_settings: {"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true}}"
#
#==> @default_delivery_system: "test_api_client"
#
#==> @message: #<Mail::Message:61160, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60052c37c7a8c_165c5ebb41651a"; charset=UTF-8>>
#
#------------------------------- Methods -------------------------------
#
#==> client: TestApiClientClass
#
#==> delivery_system: "test_api_client"
#
#==> delivery_options: [:from, :to, :subject, :text_part, :html_part]
#
#==> delivery_data: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
#
#==> settings: {:return_response=>true, :fake_plugger_debug=>true}
#
#=======================================================================
#
# => #<TestApiClientClass:0x00007ff1c88e2c60 @settings={:api_key=>"12345"}, @options={"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}>
```

Let's add fake response as well in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true, fake_plugger_response: { status: :ok } }
  api.client = TestApiClientClass
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 18.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"OK"}
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 62.2ms
#Sent mail to to@example.com (12.2ms)
#Date: Sat, 02 Jan 2021 15:08:53 +0100
#From: from@example.com
#To: to@example.com
#Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_5ff07e75956a7_104cfebb498739";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_5ff07e75956a7_104cfebb498739
#Content-Type: text/html;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#<!DOCTYPE html>
#<html>
#  <head>
#    <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
#    <style>
#      /* Email styles need to be inline */
#    </style>
#  </head>
#
#  <body>
#    <p>Test email body</p>
#
#  </body>
#</html>
#
#----==_mimepart_5ff07e75956a7_104cfebb498739--

#=> #<Mail::Message:61100, Multipart: true, Headers: <Date: Sat, 02 Jan 2021 15:08:53 +0100>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <5ff07e7597b40_104cfebb4988d3@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff07e75956a7_104cfebb498739"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 20.9ms
# => {:status=>:ok}
```
