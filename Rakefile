# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rdoc/task'

RSpec::Core::RakeTask.new(:spec)

RDoc::Task.new do |rdoc|
  rdoc.main       = 'README.md'
  rdoc.title      = 'OFX Kit'
  rdoc.rdoc_dir   = 'docs'
  rdoc.markup     = 'rdoc'
  rdoc.rdoc_files.include('README.md', 'CHANGELOG.md', 'lib/**/*.rb')
  rdoc.rdoc_files.exclude('lib/**/*_internal.rb', 'lib/generators/**/*.rb')
end

# Force full regeneration on every run.
# Prepend clobber_rdoc so it runs *before* the file task that generates docs.
Rake::Task[:rdoc].prerequisites.unshift('clobber_rdoc')

task default: :spec
