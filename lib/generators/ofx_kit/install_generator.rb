# frozen_string_literal: true

require 'rails/generators'

module OFX
  module Generators
    # Generates an OFX Kit initializer with all configuration options
    # pre-written and commented, ready to uncomment and customize.
    #
    # === Example
    #
    #   rails generate ofx_kit:install
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Creates an OFX Kit initializer at config/initializers/ofx_kit.rb'

      def copy_initializer
        copy_file 'ofx_kit.rb', 'config/initializers/ofx_kit.rb'
      end
    end
  end
end
