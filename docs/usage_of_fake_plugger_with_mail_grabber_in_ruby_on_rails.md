# How to use FakePlugger with MailGrabber in Ruby on Rails

**This Class was made for development and testing purpose. Please do not use on production environment.**

After to add `mail_plugger`, `mail_grabber` gems and if we are using API then the gem of API of the mail provider, create `config/initializers/mail_plugger.rb` file and add something similar.


If we are using SMTP

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    fake_plugger_use_mail_grabber: true
  }
end
```

If we are using API


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
  api.delivery_settings = { fake_plugger_use_mail_grabber: true }
  api.client = TestApiClientClass
end
```

Then change `config/environments/development.rb` file.

```ruby
config.action_mailer.delivery_method = :fake_plugger
```

Also add route that we can reach MailGrabber web interface. Let's change `config/routes.rb` file.

```ruby
require 'mail_grabber/web'

Rails.application.routes.draw do
  mount MailGrabber::Web => '/mail_grabber'
end
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
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.5ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 55.8ms
#Sent mail to to@example.com (36.8ms)
#Date: Tue, 13 Apr 2021 07:11:32 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60752804857d7_c43aec18576b4@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_6075280484140_c43aec1857593";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_6075280484140_c43aec1857593
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_6075280484140_c43aec1857593
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
#----==_mimepart_6075280484140_c43aec1857593--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Tue, 13 Apr 2021 07:11:32 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60752804857d7_c43aec18576b4@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_6075280484140_c43aec1857593"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Then we can check grabbed emails on the web interface. If the Rails server is running then open a browser and visit on the `http://localhost:3000/mail_grabber` page.
