# frozen_string_literal: true

require_relative 'lib/ofx_kit/version'

Gem::Specification.new do |s|
  s.name        = 'ofx_kit'
  s.version     = OFX::VERSION
  s.authors     = ['Lucas Geron']
  s.email       = 'lucasf.geron@gmail.com'
  s.summary     = 'OFX file parser for Ruby'
  s.description = 'Parses OFX 1.x and 2.x files into typed domain objects with a fluent API and configurable field mappings.'
  s.license     = 'MIT'

  s.metadata["source_code_uri"] = "https://github.com/lucasgeron/ofx_kit"
  s.metadata["changelog_uri"] = "https://lucasgeron.github.io/ofx_kit/CHANGELOG_md"
  s.metadata["documentation_uri"] = "https://lucasgeron.github.io/ofx_kit/"
  s.metadata["rubygems_mfa_required"] = "true"

  s.required_ruby_version = '>= 3.2'

  s.files = Dir['lib/**/*.{rb,yml}', 'README.md', 'LICENSE']
  s.require_paths = ['lib']

  s.add_dependency 'bigdecimal', '~> 3.1'
  s.add_dependency 'money',     '~> 6.16'
  s.add_dependency 'nokogiri',  '~> 1.13'

  s.add_development_dependency 'rake',    '~> 13.0'
  s.add_development_dependency 'rdoc',    '~> 7.2.0'
  s.add_development_dependency 'rspec',   '~> 3.13'
  s.add_development_dependency 'rubocop', '~> 1.0'
end
