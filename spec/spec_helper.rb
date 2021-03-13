# frozen_string_literal: true

# For code coverage measurements to work properly, `SimpleCov` should be loaded
# and started before any application code is loaded.
require 'simplecov'
SimpleCov.start

require 'bundler/setup'
require 'capybara/apparition'
require 'capybara/rspec'
require 'mail_plugger'
require 'mail_grabber/web'
require 'mail'

Capybara.javascript_driver = :apparition
Capybara.default_driver = Capybara.javascript_driver
Capybara.save_path = 'tmp'
Capybara.app = MailGrabber::Web
Capybara.server = :webrick

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
