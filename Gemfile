# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

# rdoc 7.2.0 on rubygems.org was published before the Aliki template received
# its method-header styling update (border-left box on method signatures).
# The fix exists on the master branch but has not yet been released as a gem.
# Once a new rdoc version ships with these changes, pin back to rubygems.
# See: https://github.com/ruby/rdoc/blob/master/lib/rdoc/generator/template/aliki/css/rdoc.css
gem 'rdoc', git: 'https://github.com/ruby/rdoc.git', branch: 'master'
