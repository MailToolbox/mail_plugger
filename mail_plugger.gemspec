require_relative 'lib/mail_plugger/version'

Gem::Specification.new do |spec|
  spec.name          = "mail_plugger"
  spec.version       = MailPlugger::VERSION
  spec.authors       = ["Norbert Szivós"]
  spec.email         = ["sysqa@yahoo.com"]

  spec.summary       = %q{Plug in the required API(s) with mail plugger.}
  spec.description   = %q{Delivery Method to send emails via the defined API(s), e.g. for Rails ActionMailer.}
  spec.homepage      = "https://github.com/norbertszivos/mail_plugger"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.3.0")

  # spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/norbertszivos/mail_plugger"
  spec.metadata["changelog_uri"] = "https://github.com/norbertszivos/mail_plugger/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
end
