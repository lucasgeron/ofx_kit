# frozen_string_literal: true

require 'nokogiri'

module OFX
  module Tokenizer
    # Tokenizer for OFX version 1 files, which use an SGML-like format.
    # Splits the file into a colon-separated header section and an SGML body,
    # then normalizes the body into valid XML before parsing with Nokogiri.
    class OFX1 < Base
      private

      def parse!
        content = convert_to_utf8(@content)
        parts   = content.split(/<OFX>/i, 2)

        raise Errors::InvalidHeaderError, 'Missing <OFX> tag in OFX file' if parts.size < 2

        @headers = parse_headers(parts[0])
        @body    = parse_body("<OFX>#{parts[1]}")
      end

      def parse_headers(raw)
        raw.lines.each_with_object({}) do |line, result|
          line = line.strip
          next if line.empty?

          key, value = line.split(':', 2)
          next unless key && value

          result[key.strip] = value.strip == 'NONE' ? nil : value.strip
        end
      end

      def parse_body(raw)
        normalized = normalize_sgml(raw)
        doc = Nokogiri::XML(normalized, &:nonet)
        raise Errors::InvalidBodyError, "OFX body could not be parsed: #{doc.errors.first}" if doc.errors.any?

        doc
      end

      def normalize_sgml(body)
        body.gsub(%r{(<([A-Z0-9_]+)>)\s*([^<\r\n][^<\r\n]*)(</\2>)?}) do
          tag_open = ::Regexp.last_match(1)
          tag_name = ::Regexp.last_match(2)
          content  = ::Regexp.last_match(3).strip
          "#{tag_open}#{content}</#{tag_name}>"
        end
      end
    end
  end
end
