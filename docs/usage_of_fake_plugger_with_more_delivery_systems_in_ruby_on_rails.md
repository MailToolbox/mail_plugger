# How to use FakePlugger with more delivery systems in Ruby on Rails

Let's modify the configuration which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_in_ruby_on_rails.md).

Change `config/initializers/mail_plugger.rb`.

```ruby
# NOTE: This is just an example for testing...
MailPlugger.plug_in('test_smtp_client') do |smtp|
  smtp.delivery_settings = {
    smtp_settings: { address: '127.0.0.1', port: 1025 },
    return_response: true,
    fake_plugger_response: 'using SMTP: OK'
  }
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
  api.delivery_settings = {
    return_response: true,
    fake_plugger_response: 'using API: OK'
  }
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
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.8ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.4ms)
#TestMailer#send_test: processed outbound mail in 32.5ms
#=> #<Mail::Message:61220, Multipart: true, Headers: <Date: Sun, 06 Jun 2021 17:47:19 +0200>, <From: from@example.com>, <To: to@example.com>, <Message-ID: <60bcee0766b04_160a6ec1814be@server.local.mail>>, <Subject: Test email>, <Mime-Version: 1.0>, <Content-Type: multipart/alternative; boundary="--==_mimepart_60bcee076528d_160a6ec181374"; charset=UTF-8>, <Content-Transfer-Encoding: 7bit>, <delivery-system: test_smtp_client>>

# or

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 21.8ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test2 email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test2 email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}]}
#=> {:response=>"Message sent via API"}
```

Let's try the same thing in `rails console -e test`

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (1.0ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 23.8ms
# => "using SMTP: OK"

# or

TestMailer.send_test2.deliver_now!
#  Rendering test_mailer/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer/send_test2.html.erb within layouts/mailer (0.4ms)
#  Rendering test_mailer/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer/send_test2.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test2: processed outbound mail in 7.1ms
# => "using API: OK"
```