# frozen_string_literal: true

require 'rails/generators'

module Ofx
  module Generators
    # Ejects OFX field mappings into the Rails application so they can be customized.
    #
    # Creates +config/initializers/ofx_mappings.yml+ with the gem's default field
    # mappings. The file is auto-detected and loaded by the OFX gem on boot —
    # no initializer or +OFX.configure+ call is needed.
    #
    # @example
    #   rails generate ofx:eject
    class EjectGenerator < Rails::Generators::Base
      source_root File.expand_path('templates', __dir__)

      desc 'Ejects OFX field mappings into config/initializers/ofx_mappings.yml'

      def eject_mappings
        copy_file 'ofx_mappings.yml', 'config/initializers/ofx_mappings.yml'
      end
    end
  end
end
