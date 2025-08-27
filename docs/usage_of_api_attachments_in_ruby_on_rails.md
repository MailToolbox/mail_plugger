# How to use the API delivery system that adds attachments to the mailer method in Ruby on Rails

Let's use the mailer method that was defined [here](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md#api).

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
      attachments: generate_attachments
    }
  end

  def generate_recipients
    @options[:to].map do |to|
      {
        email: to
      }
    end
  end

  def generate_attachments
    @options[:attachments].map do |attachment|
      hash = {
          filename: attachment[:filename],
          type: attachment[:type],
          content: attachment[:content]
        }
      hash.merge!(content_id: attachment[:cid]) if attachment.has_key?(:cid)

      hash
    end
  end
end

MailPlugger.plug_in('test_api_client') do |api|
  api.client = TestApiClientClass
  api.delivery_options = %i[from to subject text_part html_part attachments]
  api.delivery_settings = { return_response: true }
end
```

Let's change the `app/mailers/test_mailer.rb` file.

```ruby
class TestMailer < ApplicationMailer
  default from: 'from@example.com'

  def send_test
    attachments['image1.png'] = File.read('/path/to/image1.png')
    attachments.inline['image2.png'] = File.read('/path/to/image2.png')

    mail subject: 'Test email', to: 'to@example.com'
  end
end
```

Then change the `app/views/test_mailer/send_test.html.erb` file and add an inline attachment.

```erb
<p>Test email body</p>
<%= image_tag attachments['image2.png'].url %>
```

In the `rails console`, we can try it out.

```ruby
TestMailer.send_test.deliver_now!
#  Rendering test_mailer/send_test.html.erb within layouts/mailer
#  Rendered test_mailer/send_test.html.erb within layouts/mailer (4.6ms)
#  Rendering test_mailer/send_test.text.erb within layouts/mailer
#  Rendered test_mailer/send_test.text.erb within layouts/mailer (0.3ms)
#TestMailer#send_test: processed outbound mail in 47.5ms
# >>> settings: {:api_key=>"12345"}
# >>> options: {"from"=>["from@example.com"], "to"=>["to@example.com"], "subject"=>"Test email", "text_part"=>"Test email body\n\n", "html_part"=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n<img src=\"cid:5ffdd449d282a_163e2ef9c62c0@server.local.mail\" />\n\n  </body>\n</html>\n", "attachments"=>[{"filename"=>"image1.png", "type"=>"image/png", "content"=>"iVBORw0KGgoAAAANSUhEUgAAALQAAABdCAMAAAA7WLggg==\n"}, {"cid"=>"5ffdd449d282a_163e2ef9c62c0@server.local.mail", "filename"=>"image2.png", "type"=>"image/png", "content"=>"iVBORw0KGgoAAAANSUhEUgAAAAggg==\n"}]}
# >>> generate_mail_hash: {:to=>[{:email=>"to@example.com"}], :from=>{:email=>"from@example.com"}, :subject=>"Test email", :content=>[{:type=>"text/plain", :value=>"Test email body\n\n"}, {:type=>"text/html; charset=UTF-8", :value=>"<!DOCTYPE html>\n<html>\n  <head>\n    <meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\" />\n    <style>\n      /* Email styles need to be inline */\n    </style>\n  </head>\n\n  <body>\n    <p>Test email body</p>\n<img src=\"cid:5ffdd449d282a_163e2ef9c62c0@server.local.mail\" />\n\n  </body>\n</html>\n"}], :attachments=>[{:filename=>"image1.png", :type=>"image/png", :content=>"iVBORw0KGgoAAAANSUhEUgAAALQAAABdCAMAAAA7WLggg==\n"}, {:filename=>"image2.png", :type=>"image/png", :content=>"iVBORw0KGgoAAAANSUhEUgAAAAggg==\n", :content_id=>"5ffdd449d282a_163e2ef9c62c0@server.local.mail"}]}
#=> {:response=>"OK"}
```
