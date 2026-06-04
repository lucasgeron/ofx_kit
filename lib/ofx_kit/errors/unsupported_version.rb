# frozen_string_literal: true

module OFX
  class Error
    # Raised when the OFX version declared in the header is not supported.
    class UnsupportedVersion < Error
      attr_reader :version

      def initialize(version)
        @version = version
        super("Unsupported OFX version: #{version}")
      end
    end
  end
end
