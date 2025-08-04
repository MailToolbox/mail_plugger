# M<img src="https://raw.githubusercontent.com/MailToolbox/mail_plugger/main/images/mail_plugger800x500.png" height="22" />ilPlugger

[![Gem Version](https://badge.fury.io/rb/mail_plugger.svg)](https://badge.fury.io/rb/mail_plugger)
[![MIT license](https://img.shields.io/badge/license-MIT-brightgreen)](https://github.com/MailToolbox/mail_plugger/blob/main/LICENSE.txt)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![MailPlugger CI](https://github.com/MailToolbox/mail_plugger/actions/workflows/mail_plugger_ci.yml/badge.svg)](https://github.com/MailToolbox/mail_plugger/actions/workflows/mail_plugger_ci.yml)
[![Maintainability](https://qlty.sh/gh/MailToolbox/projects/mail_plugger/maintainability.svg)](https://qlty.sh/gh/MailToolbox/projects/mail_plugger)
[![Code Coverage](https://qlty.sh/gh/MailToolbox/projects/mail_plugger/coverage.svg)](https://qlty.sh/gh/MailToolbox/projects/mail_plugger)

**MailPlugger** helps you to use one or more mail providers. You can send emails via SMTP and API as well.

Also, it can help:
- move between mail providers
- load balancing
- cost management

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mail_plugger'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install mail_plugger

## Usage

- [How to use MailPlugger.configure method](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_configure_method.md)
- [How to use MailPlugger.plug_in method](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_plug_in_method.md)
- [How to use MailPlugger::DeliveryMethod class](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_delivery_method.md)
- [How to use MailPlugger in a Ruby script or IRB console](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_script_or_console.md)
- [How to use MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md)
  - [How to use MailPlugger.configure method in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_configure_method_in_ruby_on_rails.md)
  - [How to use more SMTP delivery systems in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_more_smtp_delivery_systems_in_ruby_on_rails.md)
  - [How to combine SMTP and API delivery systems in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_smtp_and_api_delivery_systems_in_ruby_on_rails.md)
  - [How to add API specific options to the mailer method in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_api_specific_options_in_ruby_on_rails.md)
  - [How to use API delivery system that add attachments to the mailer method in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_api_attachments_in_ruby_on_rails.md)
  - [How to use more API delivery systems in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_more_api_delivery_systems_in_ruby_on_rails.md)
  - [How to use one API delivery system with more send methods in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_one_api_delivery_system_with_more_send_methods_in_ruby_on_rails.md)
  - [How to use AWS SES API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_aws_ses_api_in_ruby_on_rails.md)
  - [How to use SparkPost API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_sparkpost_api_in_ruby_on_rails.md)
  - [How to use SendGrid API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_sendgrid_api_in_ruby_on_rails.md)
  - [How to use Mandrill API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_mandrill_api_in_ruby_on_rails.md)
  - [How to use Postmark API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_postmark_api_in_ruby_on_rails.md)
  - [How to use Mailgun API with MailPlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_mailgun_api_in_ruby_on_rails.md)

# F<img src="https://raw.githubusercontent.com/MailToolbox/mail_plugger/main/images/fake_plugger800x500.png" height="22" />kePlugger

**FakePlugger** is a delivery method to mock **MailPlugger**. It is working similarly like **MailPlugger**, but it won't send any emails (but if we would like it is possible, just we should do manually). Also, it can write out debug information, or we can manipulate the response with it. Another option that we can use **[MailGrabber](https://github.com/MailToolbox/mail_grabber)** web interface if the delivery method is `:fake_plugger`.

## Usage

- [How to use FakePlugger::DeliveryMethod class](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_delivery_method.md)
- [How to use FakePlugger in a Ruby script or IRB console](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_in_script_or_console.md)
- [How to use FakePlugger in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_in_ruby_on_rails.md)
  - [How to use FakePlugger with more delivery systems in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_with_more_delivery_systems_in_ruby_on_rails.md)
  - [How to use FakePlugger with MailGrabber in Ruby on Rails](https://github.com/MailToolbox/mail_plugger/blob/main/docs/usage_of_fake_plugger_with_mail_grabber_in_ruby_on_rails.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

To release a new version:

- Update [CHANGELOG.md](https://github.com/MailToolbox/mail_plugger/blob/main/CHANGELOG.md)
- Update the version number in `version.rb` manually or use `gem-release` gem and run `gem bump -v major|minor|patch|rc|beta`.
- Build gem with `bundle exec rake build`.
- Run `bundle install` and `bundle exec appraisal install` to update gemfiles and commit the changes.
- Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome. Please read [CONTRIBUTING.md](https://github.com/MailToolbox/mail_plugger/blob/main/CONTRIBUTING.md) if you would like to contribute to this project.

## Inspiration

- [T-mailer](https://github.com/100Starlings/t-mailer)
- [Mandrill DM](https://github.com/kshnurov/mandrill_dm)
- [SparkPost Rails](https://github.com/the-refinery/sparkpost_rails)
- and other solutions regarding in this topic

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/MailToolbox/mail_plugger/blob/main/LICENSE.txt).
