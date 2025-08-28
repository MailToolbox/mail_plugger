# How to use one API delivery system with different configuration options in Ruby on Rails

Let's modify the configuration that was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_more_api_delivery_systems_in_ruby_on_rails.md).

Change the API class and the `MailPlugger.plug_in` method in the `config/initializers/mail_plugger.rb` file.

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
      ],
      tag: @options[:tag],
      options: @options[:options]
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
  api.delivery_options = %i[from to subject text_part html_part tag options]
  api.delivery_settings = { return_response: true }
end
```

Then change the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', tag: 'test1', options: { open_tracking: true, click_tracking: false, transactional: true }
  end
end
```

Let's create the `app/mailers/test_mailer2.rb` file.

```ruby
class TestMaile2 < ApplicationMailer
  default from: 'from@example.com'

  def send_test2
    mail subject: 'Test email 2', to: 'to@example.com', tag: 'test2', options: { open_tracking: false, click_tracking: true, transactional: true }
  end
end
```

Then we should add views (the body) of this email, so create the `app/views/test_mailer2/send_test2.html.erb`

```erb
<p>Test email 2 body</p>
```

and the `app/views/test_mailer2/send_test2.text.erb` files.

```erb
Test email 2 body
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering layout layouts/mailer.html.erb
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (Duration: 1.2ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.html.erb (Duration: 3.4ms | GC: 0.0ms)
#  Rendering layout layouts/mailer.text.erb
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (Duration: 1.4ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.text.erb (Duration: 4.6ms | GC: 0.0ms)
#TestMailer#send_test: processed outbound mail in 345.2ms
# >>> settings: {api_key: "12345"}
# >>> options: {"from" => ["from@example.com"], "to" => ["to@example.com"], "subject" => "Test email", "text_part" => "Test email body\n", "html_part" => "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer/send_test.html.erb --><p>Test email body</p><!-- END app/views/test_mailer/send_test.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->", "tag" => "test1", "options" => {"open_tracking" => true, "click_tracking" => false, "transactional" => true}}
# >>> generate_mail_hash: {to: [{email: "to@example.com"}], from: {email: "from@example.com"}, subject: "Test email", content: [{type: "text/plain", value: "Test email body\n"}, {type: "text/html; charset=UTF-8", value: "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer/send_test.html.erb --><p>Test email body</p><!-- END app/views/test_mailer/send_test.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}], tag: "test1", options: {"open_tracking" => true, "click_tracking" => false, "transactional" => true}}
# => {response: "OK"}

TestMailer2.send_test2.deliver_now!
#  Rendering layout layouts/mailer.html.erb
#  Rendering test_mailer2/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer2/send_test2.html.erb within layouts/mailer (Duration: 1.4ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.html.erb (Duration: 3.3ms | GC: 0.0ms)
#  Rendering layout layouts/mailer.text.erb
#  Rendering test_mailer2/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer2/send_test2.text.erb within layouts/mailer (Duration: 4.1ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.text.erb (Duration: 6.6ms | GC: 0.0ms)
#TestMailer2#send_test2: processed outbound mail in 47.7ms
# >>> settings: {api_key: "12345"}
# >>> options: {"from" => ["from@example.com"], "to" => ["to@example.com"], "subject" => "Test email 2", "text_part" => "Test email 2 body\n", "html_part" => "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer2/send_test2.html.erb --><p>Test email 2 body</p><!-- END app/views/test_mailer2/send_test2.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->", "tag" => "test2", "options" => {"open_tracking" => false, "click_tracking" => true, "transactional" => true}}
# >>> generate_mail_hash: {to: [{email: "to@example.com"}], from: {email: "from@example.com"}, subject: "Test email 2", content: [{type: "text/plain", value: "Test email 2 body\n"}, {type: "text/html; charset=UTF-8", value: "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer2/send_test2.html.erb --><p>Test email 2 body</p><!-- END app/views/test_mailer2/send_test2.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}], tag: "test2", options: {"open_tracking" => false, "click_tracking" => true, "transactional" => true}}
# => {response: "OK"}
```

We can achieve the same thing if we plug in a second delivery system with the same API class, but in this case, we use the different delivery options with the different delivery systems.

Change the exists `MailPlugger.plug_in` method and add a new one as well in the `config/initializers/mail_plugger.rb` file.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.default_delivery_options = { tag: 'test1', options: { open_tracking: true, click_tracking: false, transactional: true } }
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
end

MailPlugger.plug_in('test_api_client2') do |api|
  api.client = TestApiClientClass
  api.default_delivery_options = { tag: 'test2', options: { open_tracking: false, click_tracking: true, transactional: true } }
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
end
```

Change the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_api_client'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Change the `app/mailers/test_mailer2.rb` file as well.

```ruby
class TestMailer2 < ApplicationMailer
  default from: 'from@example.com', delivery_system: 'test_api_client2'

  def send_test2
    mail subject: 'Test email 2', to: 'to@example.com'
  end
end
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering layout layouts/mailer.html.erb
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (Duration: 1.2ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.html.erb (Duration: 3.5ms | GC: 0.0ms)
#  Rendering layout layouts/mailer.text.erb
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (Duration: 1.0ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.text.erb (Duration: 4.3ms | GC: 0.0ms)
#TestMailer#send_test: processed outbound mail in 259.1ms
# >>> settings: {api_key: "12345"}
# >>> options: {"tag" => "test1", "options" => {"open_tracking" => true, "click_tracking" => false, "transactional" => true}, "from" => ["from@example.com"], "to" => ["to@example.com"], "subject" => "Test email", "text_part" => "Test email body\n", "html_part" => "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer/send_test.html.erb --><p>Test email body</p><!-- END app/views/test_mailer/send_test.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}
# >>> generate_mail_hash: {to: [{email: "to@example.com"}], from: {email: "from@example.com"}, subject: "Test email", content: [{type: "text/plain", value: "Test email body\n"}, {type: "text/html; charset=UTF-8", value: "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer/send_test.html.erb --><p>Test email body</p><!-- END app/views/test_mailer/send_test.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}], tag: "test1", options: {"open_tracking" => true, "click_tracking" => false, "transactional" => true}}
# => {response: "OK"}

TestMailer2.send_test2.deliver_now!
#  Rendering layout layouts/mailer.html.erb
#  Rendering test_mailer2/send_test2.html.erb within layouts/mailer
#  Rendered test_mailer2/send_test2.html.erb within layouts/mailer (Duration: 1.5ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.html.erb (Duration: 3.5ms | GC: 0.0ms)
#  Rendering layout layouts/mailer.text.erb
#  Rendering test_mailer2/send_test2.text.erb within layouts/mailer
#  Rendered test_mailer2/send_test2.text.erb within layouts/mailer (Duration: 3.9ms | GC: 0.0ms)
#  Rendered layout layouts/mailer.text.erb (Duration: 6.9ms | GC: 0.0ms)
#TestMailer2#send_test2: processed outbound mail in 78.2ms
# >>> settings: {api_key: "12345"}
# >>> options: {"tag" => "test2", "options" => {"open_tracking" => false, "click_tracking" => true, "transactional" => true}, "from" => ["from@example.com"], "to" => ["to@example.com"], "subject" => "Test email 2", "text_part" => "Test email 2 body\n", "html_part" => "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer2/send_test2.html.erb --><p>Test email 2 body</p><!-- END app/views/test_mailer2/send_test2.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}
# >>> generate_mail_hash: {to: [{email: "to@example.com"}], from: {email: "from@example.com"}, subject: "Test email 2", content: [{type: "text/plain", value: "Test email 2 body\n"}, {type: "text/html; charset=UTF-8", value: "<!-- BEGIN app/views/layouts/mailer.html.erb --><!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <!-- BEGIN app/views/test_mailer2/send_test2.html.erb --><p>Test email 2 body</p><!-- END app/views/test_mailer2/send_test2.html.erb -->\n  </body>\n</html>\n<!-- END app/views/layouts/mailer.html.erb -->"}], tag: "test2", options: {"open_tracking" => false, "click_tracking" => true, "transactional" => true}}
# => {response: "OK"}
```
