# Change log

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

* Add `configure` method to MailPlugger.

### Changes

* Add mail 2.8 gem support.
* Update the documentations.
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

* Add SMTP support. With this modifications we can use SMTP and API delivery methods as well.

### Changes

* Update bundler and gems.


## 1.3.0 (2021-04-14)

### New features

* Add MailGrabber to FakePlugger. Now we can use FakePlugger and MailGrabber in same time.

### Changes

* Remove unnecessary double quotes from `show_debug_info` method in `FakePlugger::DeliveryMethod` and fix documentations.
* Update bundler and gems.
* Update bug_report.md.


## 1.2.0 (2021-03-18)

### New organization

* Move mail_plugger repository into MailToolbox organization.

### Changes

* Update gems.
* Fix some documentation issues.


## 1.1.1 (2021-01-21)

### Changes

* Change `FakePlugger::DeliveryMethod` to returns with the extracted delivery data instead of the message object.
* Update code documentations.
* Add missing FakePlugger description in the README.md.


## 1.1.0 (2021-01-18)

### New features

* Add FakePlugger to mock MailPlugger.

### Changes

* Fix typos in the documentations.
* Add more metadata to gempspec file.


## 1.0.1 (2021-01-15)

### Changes

* Tidy up the gemspec file and change which files contains in the gem. Now the gem is much smaller.
* Add a new mail plugger image which has a different canvas and use it in the README.md.


## 1.0.0 (2021-01-14)

### Changes

* Update gems.
* Remove `webmock` gem to clean up unused things.
* Update documentations.


## 1.0.0.rc1 (2021-01-13)

### Changes

* Change description and fix changelog_uri in gemspec file.
* Add/Change documentations.
* Update gems.
* Change `MailPlugger.plug_in` and `MailPlugger::MailHelper.delivery_options` methods to accept strings and symbols.
* Change `MailPlugger::MailHelper.delivery_data` method that we can retrieve message object as well.
* Check hash keys in `MailPlugger::MailHelper.delivery_system` method, so now if we are add wrong `delivey_system` then we are getting a meaningful error message.
* Change `MailPlugger::MailHelper.extract_attachments` method. If an attachment is inline then the hash contains the `filename` and `cid` as well.
* Add/Change tests.
* Change `MailPlugger::MailHelper.delivery_option` that returns with indifferent hash.


## 1.0.0.beta1 (2021-01-02)

* Implement MailPlugger methods and functionality. See [README.md](https://github.com/MailToolbox/mail_plugger/blob/main/README.md)
