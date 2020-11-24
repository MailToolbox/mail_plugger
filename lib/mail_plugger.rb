require 'mail_plugger/version'

# If we are using this gem outside of Rails then do not load this code.
require 'mail_plugger/railtie' if defined?(Rails)

module MailPlugger
  class Error < StandardError; end
  # Your code goes here...
end
