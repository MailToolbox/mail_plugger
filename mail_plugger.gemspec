# frozen_string_literal: true

require_relative 'lib/mail_plugger/version'

Gem::Specification.new do |spec|
  spec.name          = 'mail_plugger'
  spec.version       = MailPlugger::VERSION
  spec.authors       = ['Norbert Szivós']
  spec.email         = ['sysqa@yahoo.com']

  spec.summary       = 'Plug in required mailer(s) with MailPlugger.'
  spec.description   = 'MailPlugger helps you to use one or more mail ' \
                       'providers. You can send emails via SMTP and API ' \
                       'as well.'
  spec.homepage      = 'https://github.com/MailToolbox/mail_plugger'
  spec.license       = 'MIT'

  spec.required_ruby_version = Gem::Requirement.new('>= 3.2.0')

  spec.extra_rdoc_files = ['LICENSE.txt', 'README.md']

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] =
    'https://github.com/MailToolbox/mail_plugger'
  spec.metadata['changelog_uri'] =
    'https://github.com/MailToolbox/mail_plugger/blob/main/CHANGELOG.md'
  spec.metadata['bug_tracker_uri'] =
    'https://github.com/MailToolbox/mail_plugger/issues'
  spec.metadata['documentation_uri'] = 'https://rubydoc.info/gems/mail_plugger'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = %w[README.md CHANGELOG.md LICENSE.txt] + Dir.glob('lib/**/*')
  spec.require_paths = ['lib']

  spec.add_dependency 'mail', '~> 2.5'
  spec.add_dependency 'net-smtp', '~> 0.3'
end
