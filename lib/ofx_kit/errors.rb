# frozen_string_literal: true

module OFX
  # Base error class for all OFX-related exceptions.
  class Error < StandardError; end

  # Raised when the OFX file cannot be parsed.
  class ParseError < Error; end

  # Raised when the OFX file header is malformed or missing.
  class InvalidHeaderError < ParseError; end

  # Raised when the OFX file body cannot be parsed into a valid document.
  class InvalidBodyError < ParseError; end

  # Raised when the OFX version declared in the file is not supported.
  class UnsupportedVersionError < Error
    # @return [String] the unsupported version string found in the file
    attr_reader :version

    # @param version [String] the unsupported OFX version string
    def initialize(version)
      @version = version
      super("Unsupported OFX version: #{version}")
    end
  end

  # Raised when a character encoding error occurs while reading the OFX file.
  class EncodingError < Error; end

  # Raised when the library configuration is invalid or inconsistent.
  class ConfigurationError < Error; end

  # Raised when an operation requires a single statement but multiple were found.
  class MultipleStatementsError < Error; end
end
