**Go To:**

- [How to use FakePlugger in Ruby on Rails](#how-to-use-fakeplugger-in-ruby-on-rails)
  - [SMTP](#smtp)
  - [API](#api)


# How to use FakePlugger in Ruby on Rails

**This Class was made for development and testing purpose. Please do not use on production environment.**

## SMTP

After to add `mail_plugger` gem, create `config/initializers/mail_plugger.rb` file and add something similar.

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
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
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 47.5ms
#Sent mail to to@example.com (246.3ms)
#Date: Sun, 06 Jun 2021 11:19:54 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc933a69466_df4eec18615ab@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc933a6823b_df4eec18614d7";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc933a6823b_df4eec18614d7
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc933a6823b_df4eec18614d7
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
#----==_mimepart_60bc933a6823b_df4eec18614d7--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:19:54 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc933a69466_df4eec18615ab@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc933a6823b_df4eec18614d7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 22.9ms
#=> #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:22:32 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc93d8a8437_df4eec1861752@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc93d8a3e76_df4eec18616bf"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 38.0ms
#Sent mail to to@example.com (11.9ms)
#Date: Sun, 06 Jun 2021 11:24:17 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc9441c7d48_e0c5ec045278a@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc9441c603d_e0c5ec04526e7";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc9441c603d_e0c5ec04526e7
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc9441c603d_e0c5ec04526e7
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
#----==_mimepart_60bc9441c603d_e0c5ec04526e7--
#
# => #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:24:17 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9441c7d48_e0c5ec045278a@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9441c603d_e0c5ec04526e7"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 2.6ms
# => #<Mail::Message:61260, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc945431b46_e0c5ec045286b"; charset=UTF-8>>
```

Let's add `return_response: true` to the delivery settings as well in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true
  }
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 36.2ms
#Sent mail to to@example.com (24.9ms)
#Date: Sun, 06 Jun 2021 11:33:50 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc967e6389e_e3ddec182081f@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc967e62475_e3ddec18207a4";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc967e62475_e3ddec18207a4
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc967e62475_e3ddec18207a4
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
#----==_mimepart_60bc967e62475_e3ddec18207a4--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:33:50 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc967e6389e_e3ddec182081f@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc967e62475_e3ddec18207a4"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 17.2ms
#=> #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:33:53 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9681d13bf_e3ddec1821061@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9681ced00_e3ddec1820931"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.7ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 25.5ms
#Sent mail to to@example.com (3.3ms)
#Date: Sun, 06 Jun 2021 11:38:29 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc979539d18_e570ec0415767@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc979538eff_e570ec0415674";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc979538eff_e570ec0415674
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc979538eff_e570ec0415674
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
#----==_mimepart_60bc979538eff_e570ec0415674--
#
# => #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:38:29 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc979539d18_e570ec0415767@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc979538eff_e570ec0415674"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 3.6ms
# => #<Mail::Message:61260, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc97a55bca4_e570ec04158f"; charset=UTF-8>>

# if it returns with the message object then we can call the deliver method to send the email.

TestMailer.send_test.deliver_now!.deliver
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 2.7ms
#Sent mail to to@example.com (20.6ms)
#Date: Sun, 06 Jun 2021 11:39:04 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc97b8bae59_e570ec04161ee@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc97b8ba738_e570ec0416044";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc97b8ba738_e570ec0416044
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc97b8ba738_e570ec0416044
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
#----==_mimepart_60bc97b8ba738_e570ec0416044--
#
# => #<Mail::Message:61300, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:39:04 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc97b8bae59_e570ec04161ee@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc97b8ba738_e570ec0416044"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's add debug option as well in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true,
    fake_plugger_debug: true
  }
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 45.0ms
#Sent mail to to@example.com (26.3ms)
#Date: Sun, 06 Jun 2021 11:48:29 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc99ed3626d_e8a2ec18635e2@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc99ed34f96_e8a2ec18634f9";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc99ed34f96_e8a2ec18634f9
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc99ed34f96_e8a2ec18634f9
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
#----==_mimepart_60bc99ed34f96_e8a2ec18634f9--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:48:29 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc99ed3626d_e8a2ec18635e2@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc99ed34f96_e8a2ec18634f9"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.2ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.7ms)
#TestMailer#send_test: processed outbound mail in 31.6ms
#=> #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:48:30 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc99eebb552_e8a2ec18637df@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc99eeb82f2_e8a2ec1863684"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.3ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 46.3ms
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true}}
#
#==> @default_delivery_system: "test_smtp_client"
#
#==> @message: #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:50:34 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9a6ac0c6a_e993ec04919df@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9a6abe156_e993ec049187c"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: "test_smtp_client"
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true}
#
#=======================================================================
#
#Sent mail to to@example.com (17.1ms)
#Date: Sun, 06 Jun 2021 11:50:34 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc9a6ac0c6a_e993ec04919df@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc9a6abe156_e993ec049187c";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc9a6abe156_e993ec049187c
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc9a6abe156_e993ec049187c
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
#----==_mimepart_60bc9a6abe156_e993ec049187c--
#
# => #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:50:34 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9a6ac0c6a_e993ec04919df@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9a6abe156_e993ec049187c"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 2.5ms
#
#===================== FakePlugger::DeliveryMethod =====================
#
#------------------------------ Variables ------------------------------
#
#==> @delivery_settings: {"test_smtp_client"=>{:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true}}
#
#==> @default_delivery_system: "test_smtp_client"
#
#==> @message: #<Mail::Message:61260, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9a6e1ee37_e993ec04920b"; charset=UTF-8>>
#
#------------------------------- Methods -------------------------------
#
#==> delivery_system: "test_smtp_client"
#
#==> settings: {:smtp_settings=>{:address=>"127.0.0.1", :port=>1025}, :return_response=>true, :fake_plugger_debug=>true}
#
#=======================================================================
#
# => #<Mail::Message:61260, Multipart: true, Headers: <From: from@example.com>, <To: to@example.com>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9a6e1ee37_e993ec04920b"; charset=UTF-8>>
```

Let's add fake response in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true,
    fake_plugger_response: 'OK'
  }
end
```

Then in the `rails console`.

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 35.6ms
#Sent mail to to@example.com (18.8ms)
#Date: Sun, 06 Jun 2021 11:56:30 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc9bcee0b9c_eb83ec18858df@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc9bcedec72_eb83ec1885761";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc9bcedec72_eb83ec1885761
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc9bcedec72_eb83ec1885761
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
#----==_mimepart_60bc9bcedec72_eb83ec1885761--
#
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:56:30 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9bcee0b9c_eb83ec18858df@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9bcedec72_eb83ec1885761"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.1ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.1ms)
#TestMailer#send_test: processed outbound mail in 19.9ms
#=> #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:56:32 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9bd077b15_eb83ec188609d@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9bd07311e_eb83ec188598d"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 25.4ms
#Sent mail to to@example.com (3.5ms)
#Date: Sun, 06 Jun 2021 11:58:23 +0200
#From: from@example.com
#To: to@example.com
#Message-ID: <60bc9c3fddba1_ec40ec04957@server.local.mail>
#Subject: Test email
#Mime-Version: 1.0
#Content-Type: multipart/alternative;
# boundary="--==_mimepart_60bc9c3fdcece_ec40ec048fa";
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#
#----==_mimepart_60bc9c3fdcece_ec40ec048fa
#Content-Type: text/plain;
# charset=UTF-8
#Content-Transfer-Encoding: 7bit
#
#Test email body
#
#
#----==_mimepart_60bc9c3fdcece_ec40ec048fa
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
#----==_mimepart_60bc9c3fdcece_ec40ec048fa--
#
# => #<Mail::Message:61240, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 11:58:23 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bc9c3fddba1_ec40ec04957@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bc9c3fdcece_ec40ec048fa"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

# or use ! to not render mail

TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.0ms)
#TestMailer#send_test: processed outbound mail in 2.6ms
# => "OK"
```

## API

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
#
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
#
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
#
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
#
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
#
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
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :text_part, :html_part]}
#
#==> @delivery_settings: {"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true}}
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
#
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
#==> @delivery_options: {"test_api_client"=>[:from, :to, :subject, :text_part, :html_part]}
#
#==> @delivery_settings: {"test_api_client"=>{:return_response=>true, :fake_plugger_debug=>true}}
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

Let's add fake response in `config/initializers/mail_plugger.rb`.

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
#
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
#
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
