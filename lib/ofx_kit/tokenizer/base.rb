# frozen_string_literal: true

module OFX
  module Tokenizer # :nodoc:
    ##
    # Abstract base class for OFX tokenizers.
    # Subclasses must implement #parse! to populate +@headers+ and +@body+
    # from the raw file content.
    class Base
      ##
      # Parsed header key/value pairs (Hash).
      attr_reader :headers
      ##
      # Parsed XML body (Nokogiri::XML::Document).
      attr_reader :body

      ##
      # Creates a new tokenizer and immediately parses +content+ (raw OFX String).
      def initialize(content)
        @content = content.dup.force_encoding('UTF-8')
        parse!
      end

      private

      def parse!
        raise NotImplementedError, "#{self.class} must implement #parse!"
      end

      def convert_to_utf8(str)
        return str if str.encoding == Encoding::UTF_8 && str.valid_encoding?

        str.encode('UTF-8', invalid: :replace, undef: :replace, replace: '')
      rescue Encoding::UndefinedConversionError
        str.dup.force_encoding('ISO-8859-1').encode('UTF-8')
      end
    end
  end
end
