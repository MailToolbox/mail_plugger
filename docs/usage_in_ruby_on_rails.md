**Go To:**

- [How to use MailPlugger in Ruby on Rails](#how-to-use-mailplugger-in-ruby-on-rails)
  - [SMTP](#smtp)
  - [API](#api)


# How to use MailPlugger in Ruby on Rails

## SMTP

*This is just a theoretical example, because if we would like to use only one SMTP connection to send emails, it would be smarter to use the built-in SMTP solution of Ruby on Rails. The advantage of this solution will be much more usable when we would like to use more than one SMTP server, or we would like to combine SMTP and API connections.*


After adding the `mail_plugger` gem, create the `config/initializers/mail_plugger.rb` file and add something similar.

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
end
```

Then change the `config/application.rb` file.

```ruby
config.action_mailer.delivery_method = :mail_plugger
```

So now we should add a mailer method. Let's create the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Then we should add views (the body) of this email, so create the `app/views/test_mailer/send_test.html.erb`

```erb
<p>Test email body</p>
```

and the `app/views/test_mailer/send_test.text.erb` files.

```erb
Test email body
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 36.4ms
#Sent mail to to@example.com (264.5ms)
#Date: Mon, 31 May 2021 07:20:48 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60b4723022332_a16cec18481b7@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60b47230210ad_a16cec1848093";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60b47230210ad_a16cec1848093
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60b47230210ad_a16cec1848093
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
#----==_mimepart_60b47230210ad_a16cec1848093--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Mon, 31 May 2021 07:20:48 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b4723022332_a16cec18481b7@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b47230210ad_a16cec1848093"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 20.5ms
#=> #<Mail::Message:61240, Multipart: true, Headers: <Date: Mon, 31 May 2021 07:24:08 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b472f8e921e_a16cec1848382@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b472f8e69f6_a16cec1848279"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

## API

After adding the `mail_plugger` gem and the gem of the API of the mail provider, create the `config/initializers/mail_plugger.rb` file and add something similar.

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
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject text_part html_part]
end
```

Then change the `config/application.rb` file.

```ruby
config.action_mailer.delivery_method = :mail_plugger
```

So now we should add a mailer method. Let's create the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Then we should add views (the body) of this email, so create the `app/views/test_mailer/send_test.html.erb`

```erb
<p>Test email body</p>
```

and the `app/views/test_mailer/send_test.text.erb` files.

```erb
Test email body
```

In the `rails console`, we can try it out.

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
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 20.9ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> #<Mail::Message:61140, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_5ff082bd7aab5_10afcebb4503a4"; charset=UTF-8>>
```

Let's add delivery settings as well in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
end
```

Then, in the `rails console`.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 37.0ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"OK"}
```
