# frozen_string_literal: true

module OFX
  module Errors
    ##
    # Raised when the OFX version declared in the file is not supported.
    class UnsupportedVersionError < Error
      ##
      # The unsupported version string found in the file (String).
      attr_reader :version

      ##
      # Creates a new error for the given unsupported +version+ string.
      def initialize(version)
        @version = version
        super("Unsupported OFX version: #{version}")
      end
    end
  end
end
