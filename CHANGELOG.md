# Change log

## 1.9.1 (2026-01-13)

### Changes

* Add mail 2.9 gem support.


## 1.9.0 (2026-01-13)

### Changes

* Add Ruby 4.0 support.
* Drop Ruby 3.0 and 3.1 support.
* Update MailGrabber to version 1.5.0.
* Update bundler and gems.
* Update documentation.
* Migrate CodeClimate to Qlty.
* Follow the rubocop changes in the configuration file.


## 1.8.0 (2025-01-07)

### Changes

* Add Ruby 3.4 support.
* Drop Ruby 2.7 support.
* Update MailGrabber to version 1.4.1.
* Update bundler and gems.


## 1.7.7 (2024-09-25)

### Changes

* Update MailGrabber to version 1.3.7 because of security issues in the webrick gem.
* Update gems.


## 1.7.6 (2024-03-05)

### Changes

* Update MailGrabber to version 1.3.6 because of security issues in the rack gem.
* Update gems.


## 1.7.5 (2024-02-20)

### Changes

* Add Ruby 3.3 support.
* Update MailGrabber to version 1.3.5.
* Update the appraisal gem with the official version.
* Update bundler and gems.


## 1.7.4 (2023-05-19)

### Changes

* Add Ruby 3.2 support.
* Update MailGrabber to version 1.3.4.
* Update the appraisal gem from GitHub to fix issues.
* Update bundler and gems.


## 1.7.3 (2023-03-19)

### Changes

* Update MailGrabber to version 1.3.3 because of security issues in the rack gem.
* Update gems.


## 1.7.2 (2023-03-11)

### Changes

* Update MailGrabber to version 1.3.2 because of security issues in the rack gem.
* Update bundler and gems.


## 1.7.1 (2023-01-25)

### Changes

* Update MailGrabber to version 1.3.1 because of security issues in the rack gem.
* Update bundler and gems.


## 1.7.0 (2022-12-27)

### New features

* Add a `configure` method to MailPlugger.

### Changes

* Add mail 2.8 gem support.
* Update the documentation.
* Change RuboCop rules.
* Update gem description.
* Refactor RSpec tests.
* Update bundler and gems.

### Bug fixes

* Fix the Ruby version problem in the GitHub Actions workflow file.


## 1.6.1 (2022-05-27)

### Changes

* Update MailGrabber to version 1.2.1 because of security issues in the rack gem.


## 1.6.0 (2022-05-26)

### Changes

* Drop Ruby 2.6 support.
* Fix some grammar issues and typos.
* Update bundler and gems.


## 1.5.0 (2021-12-31)

### Changes

* Add Ruby 3.1 support.
* Drop Ruby 2.5 support.
* Require MFA on RubyGems.
* Update bundler and gems.
* Fix typo in the README.md.
* Replace Travis with GitHub Actions.


## 1.4.0 (2021-06-08)

### New features

* Add SMTP support. With these modifications, we can use SMTP and API delivery methods as well.

### Changes

* Update bundler and gems.


## 1.3.0 (2021-04-14)

### New features

* Add MailGrabber to FakePlugger. Now we can use FakePlugger and MailGrabber at the same time.

### Changes

* Remove unnecessary double quotes from the `show_debug_info` method in `FakePlugger::DeliveryMethod` and fix documentation.
* Update bundler and gems.
* Update bug_report.md.


## 1.2.0 (2021-03-18)

### New organization

* Move the mail_plugger repository into the MailToolbox organization.

### Changes

* Update gems.
* Fix some documentation issues.


## 1.1.1 (2021-01-21)

### Changes

* Change `FakePlugger::DeliveryMethod` to return with the extracted delivery data instead of the message object.
* Update code documentation.
* Add the missing FakePlugger description in the README.md.


## 1.1.0 (2021-01-18)

### New features

* Add FakePlugger to mock MailPlugger.

### Changes

* Fix typos in the documentation.
* Add more metadata to the gempspec file.


## 1.0.1 (2021-01-15)

### Changes

* Tidy up the gemspec file and change which files are contained in the gem. Now the gem is much smaller.
* Add a new mail plugger image that has a different canvas and use it in the README.md.


## 1.0.0 (2021-01-14)

### Changes

* Update gems.
* Remove the `webmock` gem to clean up unused things.
* Update documentation.


## 1.0.0.rc1 (2021-01-13)

### Changes

* Change description and fix changelog_uri in gemspec file.
* Add/Change documentation.
* Update gems.
* Change `MailPlugger.plug_in` and `MailPlugger::MailHelper.delivery_options` methods to accept strings and symbols.
* Change `MailPlugger::MailHelper.delivery_data` method so that we can retrieve the message object as well.
* Check hash keys in `MailPlugger::MailHelper.delivery_system` method, so now if we add a wrong `delivery_system`, then we are getting a meaningful error message.
* Change `MailPlugger::MailHelper.extract_attachments` method. If an attachment is inline, then the hash contains the `filename` and `cid` as well.
* Add/Change tests.
* Change `MailPlugger::MailHelper.delivery_option` that returns with an indifferent hash.


## 1.0.0.beta1 (2021-01-02)

* Implement MailPlugger methods and functionality. See [README.md](https://github.com/MailToolbox/mail_plugger/blob/main/README.md)
