# frozen_string_literal: true

module OFX
  class Error < StandardError; end

  class ParseError < Error; end

  class InvalidHeaderError < ParseError; end

  class InvalidBodyError < ParseError; end

  class UnsupportedVersionError < Error
    attr_reader :version

    def initialize(version)
      @version = version
      super("Unsupported OFX version: #{version}")
    end
  end

  class EncodingError < Error; end

  class ConfigurationError < Error; end

  class MultipleStatementsError < Error; end
end
