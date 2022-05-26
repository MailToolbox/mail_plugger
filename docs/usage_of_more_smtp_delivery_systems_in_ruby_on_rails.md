# How to use more SMTP delivery systems in Ruby on Rails

Let's modify the configuration which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#smtp).

Add another SMTP client in `config/initializers/mail_plugger.rb`.

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1025 } }
end

MailPlugger.plug_in('test_smtp2_client') do |smtp|
  smtp.delivery_settings = { smtp_settings: { address: '127.0.0.1', port: 1026 } }
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
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_smtp2_client'
  end
end
```

Then we should add views of the second mailer method, so create `app/views/test_mailer/send_test2.html.erb`

```erb
<p>Test email body</p>
```

and `app/views/test_mailer/send_test2.text.erb`.

```erb
Test email body
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 47.8ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:24:29 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b7160d998eb_14341ec18223d@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b7160d97de4_14341ec1822268"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.5ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 29.1ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:25:45 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b71659f1a9c_14341ec18225d@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b71659ecb72_14341ec182249a"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp2_client>>
```

In the `app/mailers/test_mailer.rb` file, we can use the Rails default option as well to define `delivery_system`.

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
#TestMailer#send_test: processed outbound mail in 34.7ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:27:34 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b716c62e40b_14472ec187637b@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b716c62bebd_14472ec187628e"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.5ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test2: processed outbound mail in 17.4ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:27:36 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b716c84b0a7_14472ec18765b0@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b716c848d25_14472ec18764d4"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>
```

Or we can use default, but override it in the method.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_smtp_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_smtp2_client'
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
#TestMailer#send_test: processed outbound mail in 30.3ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:30:11 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b71763c7ed1_14571ec186207@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b71763c6784_14571ec18619ae"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.5ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test2: processed outbound mail in 16.8ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:30:13 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b71765acdd6_14571ec186227c@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b71765aab59_14571ec18621bb"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp2_client>>
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
#TestMailer#send_test: processed outbound mail in 30.0ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:32:07 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b717d78543a_14638ec181502b@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b717d783a68_14638ec18149bf"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 16.6ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:32:09 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b717d91a24e_14638ec181526@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b717d917fcd_14638ec18151f5"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>
```

Or we can just define `delivery_system` where we would like to use the other one.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end

  def send_test2
    mail subject: 'Test2 email', to: 'to@example.com', delivery_system: 'test_smtp2_client'
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
#TestMailer#send_test: processed outbound mail in 31.4ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:33:59 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b71847251c3_146fbec1880754@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b7184723604_146fbec188069c"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>>

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.3ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 15.8ms
#=> #<Mail::Message:61280, Multipart: true, Headers: <Date: Wed, 02 Jun 2021 07:34:00 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60b71848e065c_146fbec1880961@server.local.mail>>, <Subject: Test2 email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60b71848de435_146fbec1880876"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp2_client>>
```
