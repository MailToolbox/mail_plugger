# frozen_string_literal: true

require_relative 'lib/mail_plugger/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_plugger'
  spec.version       = MailPlugger::VERSION
  spec.authors       = ['Norbert Szivós']
  spec.email         = ['sysqa@yahoo.com']

  spec.summary       = 'Plug in the required mailer API(s) with MailPlugger.'
  spec.description   = 'Delivery Method to send emails via API(s). We can ' \
                       'use this Delivery Method with Ruby on Rails ' \
                       'ActionMailer or other solutions.'
  spec.homepage      = 'https://github.com/norbertszivos/mail_plugger'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.extra_rdoc_files = ['LICENSE.txt', 'README.md']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/norbertszivos/mail_plugger'
  spec.metadata['changelog_uri'] =
    'https://github.com/norbertszivos/mail_plugger/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/norbertszivos/mail_plugger/issues'
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/mail_plugger'

  spec.files = %w[README.md CHANGELOG.md LICENSE.txt] + Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '~> 2.5'
end
