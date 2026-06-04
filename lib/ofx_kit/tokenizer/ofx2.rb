# frozen_string_literal: true

module OFX
  module Tokenizer
    # Tokenizer for OFX version 2 files, which use standard XML with an
    # OFX processing instruction for header metadata.
    class OFX2 < Base
      private

      def parse!
        content = convert_to_utf8(@content)
        doc     = Nokogiri::XML(content, &:nonet)

        raise OFX::Error::InvalidBody, "OFX2 body could not be parsed: #{doc.errors.first}" if doc.errors.any?

        @headers = parse_headers(doc)
        @body    = doc
      end

      def parse_headers(doc)
        pi = doc.children.find { |node| node.processing_instruction? && node.name == 'OFX' }
        return {} unless pi

        pi.content.scan(/(\w+)="([^"]*)"/).each_with_object({}) do |(key, value), result|
          result[key] = value == 'NONE' ? nil : value
        end
      end
    end
  end
end
