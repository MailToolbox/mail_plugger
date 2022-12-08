# How to add API specific options to the mailer method in Ruby on Rails

Let's use mailer method which was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

Change the API and `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

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
      string: @options[:string],
      boolean: @options[:boolean],
      array: @options[:array],
      hash: @options[:hash]
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
  api.delivery_options = %i[from to subject text_part html_part string boolean array hash]
  api.delivery_settings = { return_response: true }
end
```

So add special API options to the mailer method. Let's change `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com', string: 'This is the string', boolean: true, array: ['This', 'is', 'the array'], hash: { this: 'is the hash' }
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 35.3ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n", "string"=>"This is the string", "boolean"=>true, "array"=>["This", "is", "the array"], "hash"=>{"this"=>"is the hash"}}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}], :string=>"This is the string", :boolean=>true, :array=>["This", "is", "the array"], :hash=>{:this=>"is the hash"}}
#=> {:response=>"OK"}
```

If those API specific options are common, then we can use `default_delivery_options` as well.

Change `MailPlugger.plug_in` method in `config/initializers/mail_plugger.rb`.

```ruby
MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.default_delivery_options = {
    string: 'This is the string',
    boolean: true,
    array: ['This', 'is', 'the array'],
    hash: { this: 'is the hash' }
  }
  api.delivery_options = %i[from to subject text_part html_part]
  api.delivery_settings = { return_response: true }
end
```

Change `app/mailers/test_mailer.rb` file as well.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

In the `rails console` we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (0.9ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.5ms)
#TestMailer#send_test: processed outbound mail in 35.3ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"string"=>"This is the string", "boolean"=>true, "array"=>["This", "is", "the array"], "hash"=>{"this"=>"is the hash"}, "from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n\n  </body>\n</html>\n"}], :string=>"This is the string", :boolean=>true, :array=>["This", "is", "the array"], :hash=>{"this"=>"is the hash"}}
#=> {:response=>"OK"}
```
