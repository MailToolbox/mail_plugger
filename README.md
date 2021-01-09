# M<img src="https://github.com/norbertszivos/mail_plugger/blob/main/images/mail_plugger.png" height="25" />ilPlugger

[![Gem Version](https://badge.fury.io/rb/mail_plugger.svg)](https://badge.fury.io/rb/mail_plugger)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![Build Status](https://travis-ci.com/norbertszivos/mail_plugger.svg?branch=main)](https://travis-ci.com/norbertszivos/mail_plugger)
[![Maintainability](https://api.codeclimate.com/v1/badges/bd2cda43214c111d8d16/maintainability)](https://codeclimate.com/github/norbertszivos/mail_plugger/maintainability)
[![Test Coverage](https://api.codeclimate.com/v1/badges/bd2cda43214c111d8d16/test_coverage)](https://codeclimate.com/github/norbertszivos/mail_plugger/test_coverage)

**MailPlugger** helps you to use different mail providers' **API**. You can use any APIs which one would like to use. It allows you to send different emails with different APIs. Also it can help to move between providers, load balacing or cost management.

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

- [How to use MailPlugger.plug_in method](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_of_plug_in_method.md)
- [How to use MailPlugger::DeliveryMethod class](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_of_delivery_method.md)
- [Use MailPlugger in a Ruby script or IRB console](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_in_script_or_console.md)
- [Use MailPlugger in Ruby on Rails](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_in_ruby_on_rails.md)
  - [How to add API specific options to the mailer method in Ruby on Rails](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_of_secial_options_in_ruby_on_rails.md)
  - [How to use more delivey systems in Ruby on Rails](https://github.com/norbertszivos/mail_plugger/blob/main/docs/usage_of_more_delivery_system_in_ruby_on_rails.md)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome. Please read [CONTRIBUTING.md](https://github.com/norbertszivos/mail_plugger/blob/main/CONTRIBUTING.md) if you would like to contribute to this project.

## Inspiration

- [T-mailer](https://github.com/100Starlings/t-mailer)
- [Mandrill DM](https://github.com/kshnurov/mandrill_dm)
- [SparkPost Rails](https://github.com/the-refinery/sparkpost_rails)
- and other solutions regarding in this topic

## License

The gem is available as open source under the terms of the [MIT License](https://github.com/norbertszivos/mail_plugger/blob/main/LICENSE.txt).
